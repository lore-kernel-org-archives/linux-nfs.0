From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: list corruption in locks_start_grace with 2.6.28-rc3
Date: Sat, 22 Nov 2008 17:52:13 -0600
Message-ID: <49289B2D.1090404@opengridcomputing.com>
References: <x498wrokjj8.fsf@segfault.boston.devel.redhat.com>	<20081120203735.GB30808@fieldses.org>	<x49ej15gktp.fsf@segfault.boston.devel.redhat.com>	<20081122005400.GB28094@fieldses.org> <20081122092237.1ab81cdb@tleilax.poochiereds.net> <49287005.5050009@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Jeff Moyer <jmoyer@redhat.com>, linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.es335.com ([67.65.19.105]:16680 "EHLO mail.es335.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753739AbYKWAPK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 22 Nov 2008 19:15:10 -0500
In-Reply-To: <49287005.5050009@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jeff M/L:

Could you guys confirm that this patch fixes the problem? I was 
able to reproduce Jeff Layton's problem and this patch resolved
the under-reference condition for me.

Thanks,

The svc_addsock function adds transport instances without taking a
reference on the sunrpc.ko module, however, the generic transport
destruction code drops a reference when the transport instance
is destroyed.

Add a try_module_get call to the svc_addsock function for transports
added by this function.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---
 net/sunrpc/svcsock.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 95293f5..a1951dc 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1183,7 +1183,11 @@ int svc_addsock(struct svc_serv *serv,
 	else if (so->state > SS_UNCONNECTED)
 		err = -EISCONN;
 	else {
-		svsk = svc_setup_socket(serv, so, &err, SVC_SOCK_DEFAULTS);
+		if (!try_module_get(THIS_MODULE))
+			err = -ENOENT;
+		else
+			svsk = svc_setup_socket(serv, so, &err,
+						SVC_SOCK_DEFAULTS);
 		if (svsk) {
 			struct sockaddr_storage addr;
 			struct sockaddr *sin = (struct sockaddr *)&addr;
@@ -1196,7 +1200,8 @@ int svc_addsock(struct svc_serv *serv,
 			spin_unlock_bh(&serv->sv_lock);
 			svc_xprt_received(&svsk->sk_xprt);
 			err = 0;
-		}
+		} else
+			module_put(THIS_MODULE);
 	}
 	if (err) {
 		sockfd_put(so);



Tom Tucker wrote:
>
> So I think I know what's going on here. The svc_create_xprt function 
> takes a reference on the module that implements the transport and 
> svc_xprt_free releases it.
>
> The svc_xprt_free function is called from svc_xprt_put when the kref 
> goes to zero. nfsd and other services will put any transports they've 
> created when unloaded.
>
> The issue is that the "built in" transports of TCP and UDP are not 
> created with svc_create_xprt and therefore the initial transport 
> module reference is not taken. So when services exit, the sunrpc 
> module reference count is getting incorrectly decremented (twice), 
> once for TCP and once for UDP.
>
> What I don't know is what changed to cause this to happen. These 
> transports have always been created by svc_addsock and that hasn't
> changed. Maybe xcl_owner was NULL for these transports initially?
>
> I'll dig around and see what I can find out.
>
> Tom
>
> Jeff Layton wrote:
>> On Fri, 21 Nov 2008 19:54:00 -0500
>> "J. Bruce Fields" <bfields@fieldses.org> wrote:
>>
>>> On Fri, Nov 21, 2008 at 10:28:18AM -0500, Jeff Moyer wrote:
>>>> "J. Bruce Fields" <bfields@fieldses.org> writes:
>>>>
>>>>> On Wed, Nov 12, 2008 at 11:15:23AM -0500, Jeff Moyer wrote:
>>>>>> Hi,
>>>>>>
>>>>>> I'm doing some testing which involves roughly the following:
>>>>>>
>>>>>> o mount a file system on the server
>>>>>> o start the nfs service
>>>>>> - mount the nfs-exported file system from a client
>>>>>> - perform a dd from the client
>>>>>> - umount the nfs-exported file system from a client
>>>>>> o stop the nfs service
>>>>>> o unmount the file system on the server
>>>>>>
>>>>>> After several iterations of this, varying the number of nfsd threads
>>>>>> started, I get the attached backtrace.  I've reproduced it twice, 
>>>>>> now.
>>>>>>
>>>>>> Let me know if I can be of further help.
>>>>> Apologies for the delay, and thanks for the report.  Does the 
>>>>> following
>>>>> help?  (Untested).
>>>> I get a new and different backtrace with this patch applied.  ;)
>>>> I'm testing with 2.6.28-rc5, fyi.
>>> Thanks for the testing....
>>>
>>>> static inline void __module_get(struct module *module)
>>>> {
>>>>         if (module) {
>>>>                 BUG_ON(module_refcount(module) == 0);      
>>>> <------------
>>>>                 local_inc(&module->ref[get_cpu()].count);
>>>>                 put_cpu();
>>>>         }
>>>> }
>>>>
>>>> Called from net/sunrpc/svcexport.c:svc_recv:687
>>> You meant svc_xprt.c.  OK.
>>>
>>>>         } else if (test_bit(XPT_LISTENER, &xprt->xpt_flags)) {
>>>>                 struct svc_xprt *newxpt;
>>>>                 newxpt = xprt->xpt_ops->xpo_accept(xprt);
>>>>                 if (newxpt) {
>>>>                         /*
>>>>                          * We know this module_get will succeed 
>>>> because the
>>>>                          * listener holds a reference too
>>>>                          */
>>> So clearly the assumption stated in the comment is wrong.
>>>
>>> I can't see any relationship between this and the previous bug, but
>>> perhaps it was covering this up somehow.
>>>
>>>>                         __module_get(newxpt->xpt_class->xcl_owner);
>>> I don't see the problem yet, but I'll look some more....
>>>
>>
>> FWIW, I've noticed some problems with refcounting when starting and
>> stopping nfsd. When you bring it up and take it back down again
>> repeatedly (i.e. run "rpc.nfsd 1" and "rpc.nfsd 0"), you'll lose 2
>> sunrpc module refs on each cycle.
>>
>> I suspect the problem Jeff is hitting is due to that. Maybe he was just
>> reliably crashing before it got to 0 before. It's on my to-do list once
>> I get some other things off my plate. If someone wants to track it down
>> first, be my guest :)
>>
>> I have a little more info in this RHBZ, but haven't had time to nail it
>> down yet:
>>
>> https://bugzilla.redhat.com/show_bug.cgi?id=464123#c10
>>
>
> -- 
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

