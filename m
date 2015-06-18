Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60215 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753148AbbFROUl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Jun 2015 10:20:41 -0400
Message-ID: <5582D3B8.7090409@RedHat.com>
Date: Thu, 18 Jun 2015 10:20:40 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anders Blomdell <anders.blomdell@control.lth.se>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Mount regression between 4.0.4 client and 2.6.35 server
References: <55827B8D.3070103@control.lth.se>	<CAHQdGtS1affPWS=MLM8cn4C-JYjjbJUf2jHaK7uomLLkKc12HA@mail.gmail.com>	<5582B960.7000301@control.lth.se> <CAHQdGtQddKrKgoNiLyzJMupCYyVn=HUDGtXucYD+tzOhnmrD_Q@mail.gmail.com>
In-Reply-To: <CAHQdGtQddKrKgoNiLyzJMupCYyVn=HUDGtXucYD+tzOhnmrD_Q@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

BTW, I asked Anders to post this patch to 
get this discussion going. 

On 06/18/2015 08:53 AM, Trond Myklebust wrote:
> On Thu, Jun 18, 2015 at 8:28 AM, Anders Blomdell
> <anders.blomdell@control.lth.se> wrote:
>> On 2015-06-18 13:49, Trond Myklebust wrote:
>>> On Thu, Jun 18, 2015 at 4:04 AM, Anders Blomdell
>>> <anders.blomdell@control.lth.se> wrote:
>>>>
>>>> I have a problem with a 4.0.4 client refusing to mount from a 2.6.35 server
>>>> due to NFS4ERR_INVAL returned during nfs4_discover_server_trunking. See
>>>> https://bugzilla.redhat.com/show_bug.cgi?id=1228272.
>>>
>>>
>>> Why should we change the clients if the server is in clear and obvious
>>> violation of the spec?
>> In order to make clients work with servers that worked well with previous versions
>> of nfs-utils, the cultprit probably being commit f9802988 that bumped the default
>> autonegotion version to 4.2, what the patch does is only to negotiate a lower version
>> in case of errors, and hence making 1.3.2 working with servers that worked with
>> 1.3.1 (that only tried version 4[.0]).
>>
>> Will probably save some people some time.
> 
> This is what /etc/nfsmount.conf is for. We don't fix clients that are
> working correctly according to the protocol spec.
> 
Using /etc/nfsmount.conf does not scale very well when there is
a large number clients involved... 

When we bumped up the auto-negotiation to 4.2, I thinking there
would be issues with legacy servers. But I was thinking obscure 
servers like AIX would break, not old Linux servers and possibly
Solaris servers (I'm trying to check that now)

Inlining the patch:

--- utils/mount/stropts.c.orig	2015-06-18 09:51:02.091148891 +0200
+++ utils/mount/stropts.c	2015-06-18 09:48:56.859970023 +0200
@@ -838,6 +838,10 @@ check_result:
 		return result;
 
 	switch (errno) {
+	case EIO:
+		/* Fix to handle nfs4_discover_server_trunking returning
+		 * EIO in case where nfs server returns NFS4ERR_INVAL,
+		 * see https://bugzilla.redhat.com/show_bug.cgi?id=1228272 */
 	case EPROTONOSUPPORT:
 		/* A clear indication that the server or our
 		 * client does not support NFS version 4 and minor */

Now I'm not sure this is the right to handle this but 
I do think it is a good idea to make the auto-negation 
mounting code smarter to handle these legacy servers. 

steved.
