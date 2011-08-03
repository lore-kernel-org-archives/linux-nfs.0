Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:49615 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755533Ab1HCWNc convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Aug 2011 18:13:32 -0400
Subject: Re: State of NFSv4 VolatileFilehandles
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4E38F894.4070003@linux.vnet.ibm.com>
Date: Wed, 3 Aug 2011 18:13:17 -0400
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com
Message-Id: <2DD1BC2B-6113-4D00-9DD4-C5D431EA1F8A@oracle.com>
References: <4E37E66D.90102@linux.vnet.ibm.com> <45F4FC20-ED44-4430-A5A9-E06459A194F3@oracle.com> <4E38F894.4070003@linux.vnet.ibm.com>
To: Venkateswararao Jujjuri <jvrao@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Aug 3, 2011, at 3:28 AM, Venkateswararao Jujjuri wrote:

> On 08/02/2011 07:53 AM, Chuck Lever wrote:
>> On Aug 2, 2011, at 7:58 AM, Venkateswararao Jujjuri wrote:
>> 
>>> We at IBM receiving multiple customer requests for supporting NFSv4 server migration.
>>> I have referred to Trond and Chuck's presentations at 2011 Connectathon and there appears to be
>>> sizable work remaining. I am not sure if there is any progress made since those talks.
>>> 
>>> I would like to open up a discussion thread on the mailing list to understand the latest status.
>>> Also would like to get the input on the Volatile Filehandles (VFH). I searched the mailing list, and could not
>>> find any recent discussion on this.
>>> 
>>> Some discussion points:
>>> - What are the pieces left to attain full client/server support for seamless server migration?
>> The client migration implementation is code complete and in test now.  This includes both minor version 0 and 1.  We don't have any mv1 servers to test with at this time, so that support is provisional.  I hope to have patches ready for the 3.2 merge window, but you can see what I've got now on git.linux-nfs.org.
> Great I will take it from there. Is it your branch or Trand's ? Can you please give me which project/branch
> I should take from git.linux-nfs.org?

This source code is just for review and experimentation.  I would wait for the merged code upstream before basing any work on it, as it needs to be forward ported to 3.1 and I expect there will be some minor architectural changes soon.

  git://git.linux-nfs.org/projects/cel/cel-2.6.git

>> A problem is that there are corner cases in the v4.0 migration specification that are still unresolved.  We are working with the NFSv4 WG to get these addressed.  But I expect some minor changes even after the patches are merged upstream.
> What are those corner cases? Is it on any mailing list? Is it possible for us to see that discussion?

There has been a lot of face-to-face discussion about this over the past six months or so.  We are planning to bring the discussion to the nfsv4@ietf.org mailing list (which is public) very soon.

>> We don't have firm plans for a server migration implementation on Linux at this time, but Bruce can maybe say more about that.
> Sure; would wait for Bruce's views on this. We are getting requirements for both client and server support.

Are you planning to work with the kernel's NFSD, or with Ganesha?

>>> - Any discussion/sugestions on the way to implement VFH?  As described in RFC 3530 sections 4.2.3 and 4.2.4?
>> I think we are avoiding volatile file handles as long as possible.  We don't have plans to implement them at the moment.
> Hrm. How can we achieve the complete migration support without volatile filehandle support?
> What are the reasons for avoiding it? May be we can start looking into this but would like to understand
> the reasons (if any) for avoiding it.

Migration itself does not require volatile file handles (FHs).  If you are considering a simple-minded server implementation, like an rsync between heterogenous physical file systems, then yes, volatile FHs may be required.  But as Trond points out, volatile FHs are a troubled concept anyway, even without migration in the picture.

Passing a client between two servers that export the same cluster file system would be a simple and common use of migration where file handles don't have to (and probably won't) change.  We expect that the most common use cases for migration in the near term are going to involve scenarios with homogenous server OS and physical file systems, where FH format can be controlled and thus preserved across a migration event.

Robust server migration implementations, in other words, will migrate not just data, but also file handles, write verifiers, and NFSv4 state.  This allows the greatest transparency for clients, and the smoothest possible migration recovery.  Clients can be made simpler if FH recovery is not needed.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



