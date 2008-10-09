From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH 11/12] svcrdma: Add a message log string to indicate if
 FastReg is being used
Date: Thu, 09 Oct 2008 13:46:43 -0500
Message-ID: <48EE5193.2090702@opengridcomputing.com>
References: <1223069629-5267-5-git-send-email-tom@opengridcomputing.com> <1223069629-5267-6-git-send-email-tom@opengridcomputing.com> <1223069629-5267-7-git-send-email-tom@opengridcomputing.com> <1223069629-5267-8-git-send-email-tom@opengridcomputing.com> <1223069629-5267-9-git-send-email-tom@opengridcomputing.com> <1223069629-5267-10-git-send-email-tom@opengridcomputing.com> <1223069629-5267-11-git-send-email-tom@opengridcomputing.com> <1223069629-5267-12-git-send-email-tom@opengridcomputing.com> <20081008224840.GF14527@fieldses.org> <48EDA691.9080108@opengridcomputing.com> <20081009162623.GD28785@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: thomas.talpey@netapp.com, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:40793 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754474AbYJISqn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Oct 2008 14:46:43 -0400
In-Reply-To: <20081009162623.GD28785@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Thu, Oct 09, 2008 at 01:37:05AM -0500, Tom Tucker wrote:
>> J. Bruce Fields wrote:
>>> On Fri, Oct 03, 2008 at 04:33:48PM -0500, Tom Tucker wrote:
>>>   
>>>> Add a log message that allows the administrator to determine if server memory
>>>> is exposed on a particular client connection. This message can be disabled
>>>> by writing 0 to the /proc/sys/sunrpc/svc_rdma/show_conn_info file.
>>>>     
>>> I could grudgingly live with the idea of a log message here as a
>>> temporary fix while we figure out something better, but I'm not happy
>>> about making it bigger and adding a sysctl.
>>>
>>>   
>> I would happily remove all of this. I believed you thought it important  
>> that we actively informed the administrator.
>> Maybe I over-reacted.
> 
> Well, I was probably unclear and/or confused, apologies.  What I think
> would make sense for now would be just be some easy way we an
> administrator could answer the question "what kind of security model are
> my rdma interfaces using"?
> 
> A cautious administrator will want to answer these questions before
> turning on nfs over rdma, so a log message on client connect isn't as
> useful.  Also, messages to the log are fine for debugging, for notices
> about exceptional events, etc., but they aren't reliable for this kind
> of use (they get stored in distro-specific locations for varying amounts
> of time; wording may change across kernel versions, making them harder
> to grep for; etc).
> 
> So these log messages might serve as a stopgap, but I'd prefer something
> that could be queried reliably at any time.
> 
> If in addition we wanted to warn about the riskier case, maybe we could
> print a message *just* in that case (and print it only once), but I
> don't feel strongly about that.
> 
>>> If we just want a hack for now, I'd be inclined to leave this printk a
>>> dprintk, add the extra information to the dprintk, and tell people to
>>> turn on transport debugging and watch a client connect.  Ugly, but at
>>> least it'll be obvious it's not an api that's going to stick around.
>>>
>>>   
>> Id' love to get rid of it...
>>> Beyond the short-term: is there some other way of getting this
>>> information from userspace?  Since this is a property of the interface
>>> device, it'd seem natural to communicate the information in something
>>> like a sysfs file for the device, or whatever's used to query properties
>>> of network interfaces.
>>>
>>>   I'm a bit surprised the information isn't already there.  Aren't
>>> userspace applications eventually also supposed to be able to use rdma?
>>> Don't they need to query network interfaces for their capabilities?
>>>
>>>   
>> All of this information is available from  a full-function user-mode API.
> 
> Oh, cool.  So would it be difficult to write a C program that just
> printed out some basic information about the rdma-capable interfaces on
> the system?  If it didn't have a lot of dependencies, we could even
> consider adding it to nfs-utils.
> 

Coming up with a name for the command is probably
harder than writing it.

Here it is...

#include <stdlib.h>
#include <stdio.h>
#include <infiniband/verbs.h>

#define FAST_REG (1<<21) /* This will be in infiniband/verbs.h in the future */

static char *safety_string(struct ibv_device_attr *a, struct ibv_device *dev)
{
         if (a->device_cap_flags & FAST_REG
             || dev->transport_type == IBV_TRANSPORT_IB)
                 return "Safe. NFSRDMA exposes only RPC memory.\n";
         else
                 return "Unsafe. NFSRDMA exposes Server memory.\n";
}

int main(int argc, char *argv[])
{
         struct ibv_device **dev_list;
         struct ibv_context *context;
         struct ibv_device_attr attr;
         int dev_count;
         int i;

         dev_list = ibv_get_device_list(&dev_count);
         for (i = 0; dev_list && i < dev_count; i++) {
                 printf("%-20s: ", ibv_get_device_name(dev_list[i]));
                 context = ibv_open_device(dev_list[i]);
                 if (!context) {
                         printf("could not open device\n");
                         continue;
                 }
                 if (!ibv_query_device(context, &attr))
                         printf("%s\n", safety_string(&attr, dev_list[i]));
                 else
                         printf("could not query device\n");

                 ibv_close_device(context);
         }
         if (dev_list)
                 ibv_free_device_list(dev_list);

         exit(0);
}

> The one drawback is that it wouldn't be able to tell whether the
> currently running kernel actually supported fast registration.  Do you
> think a guess based on kernel version would be good enough for that?
> 

I do, yes.

>> This code makes devices more secure than they used to be. So there is no  
>> negative security regression here. This patchset simply improves the 
>> security for newer devices that support the new features.
> 
> Yes, agreed.  Just to be clear, I *have* queued up all but these last
> two patches (the printk and documentation patches) for 2.6.28.  
> 

Ok, thanks.

> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

