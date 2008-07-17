From: Carsten Aulbert <carsten.aulbert-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>
Subject: Re: Massive NFS problems on large cluster with large number of	mounts
Date: Thu, 17 Jul 2008 07:53:27 +0200
Message-ID: <487EDE57.4070100@aei.mpg.de>
References: <4869E8AB.4060905@aei.mpg.de> <20080701182250.GB21807@fieldses.org> <486B89F5.9000109@aei.mpg.de> <20080702203130.GA24850@fieldses.org> <1215032676.7087.30.camel@localhost> <487DC43F.8040408@aei.mpg.de> <20080716190658.GF20298@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org,
	Henning Fehrmann <henning.fehrmann-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>,
	Steffen Grunewald <steffen.grunewald-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from welcomes-you.com ([85.214.50.128]:51016 "EHLO
	smtp.welcomes-you.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751909AbYGQFxb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jul 2008 01:53:31 -0400
In-Reply-To: <20080716190658.GF20298@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all,

J. Bruce Fields wrote:

>> Changing /proc/sys/sunrpc/max_resvport to 1023 again resolves this
>> issue, however defeats the purpose for the initial problem. I still need
>> to look into the code for hte portmapper, but is it easily possible that
>> the portmapper would accept nfsd requests from "insecure" ports also?
>> Since e are (mostly) in a controlled environment that should not pose a
>> problem.
>>
>> Anyone with an idea?
> 
> The immediate problem seems like a kernel bug to me--it seems to me that
> the calls to local daemons should be ignoring {min_,max}_resvport.  (Or
> is there some way the daemons can still know that those calls come from
> the local kernel?)

I just found this in the Makefile for the portmapper:

# To disable tcp-wrapper style access control, comment out the following
# macro definitions.  Access control can also be turned off by providing
# no access control tables. The local system, since it runs the portmap
# daemon, is always treated as an authorized host.

HOSTS_ACCESS= -DHOSTS_ACCESS
#WRAP_LIB = $(WRAP_DIR)/libwrap.a
WRAP_LIB = -lwrap

# Comment out if your RPC library does not allocate privileged ports for
# requests from processes with root privilege, or the new portmap will
# always reject requests to register/unregister services on privileged
# ports. You can find out by running "rpcinfo -p"; if all mountd and NIS
# daemons use a port >= 1024 you should probably disable the next line.

CHECK_PORT = -DCHECK_PORT

I'll try to head down the road of not checking for the ports anymore -
on exposed ports I could block the listening daemons from the outside
world by iptables. Not nice, but probably a solution (and yet another
custom package for us).

Anyone who knows a good reason not to walk this route?

Cheers

Carsten
