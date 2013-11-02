Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:53315 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751876Ab3KBLFX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 2 Nov 2013 07:05:23 -0400
Date: Sat, 2 Nov 2013 07:05:18 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "cye@redhat.com" <cye@redhat.com>,
        "dpquigl@davequigley.com" <dpquigl@davequigley.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs: fix oops when trying to set SELinux label
Message-ID: <20131102070518.71a53424@tlielax.poochiereds.net>
In-Reply-To: <1383330580.6626.22.camel@leira.trondhjem.org>
References: <1383317372-3373-1-git-send-email-jlayton@redhat.com>
	<20131101120211.586aef7a@corrin.poochiereds.net>
	<1383324599.2911.2.camel@leira.trondhjem.org>
	<20131101125719.38843cfb@tlielax.poochiereds.net>
	<A1A30425-FA21-4D8B-ABB4-F7E02C2D5DEA@netapp.com>
	<20131101131855.224ddb4b@tlielax.poochiereds.net>
	<1383328062.6626.5.camel@leira.trondhjem.org>
	<20131101135805.56d266bd@tlielax.poochiereds.net>
	<1383330580.6626.22.camel@leira.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-7
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 1 Nov 2013 18:29:43 +-0000
+ACI-Myklebust, Trond+ACI +ADw-Trond.Myklebust+AEA-netapp.com+AD4 wrote:

+AD4 On Fri, 2013-11-01 at 13:58 -0400, Jeff Layton wrote:
+AD4 +AD4 On Fri, 1 Nov 2013 17:47:46 +-0000
+AD4 +AD4 +ACI-Myklebust, Trond+ACI +ADw-Trond.Myklebust+AEA-netapp.com+AD4 wrote:
+AD4 +AD4 
+AD4 +AD4 +AD4 On Fri, 2013-11-01 at 13:18 -0400, Jeff Layton wrote:
+AD4 +AD4 +AD4 +AD4 On Fri, 1 Nov 2013 17:05:08 +-0000
+AD4 +AD4 +AD4 +AD4 +ACI-Myklebust, Trond+ACI +ADw-Trond.Myklebust+AEA-netapp.com+AD4 wrote:
+AD4 +AD4 +AD4 +AD4 
+AD4 +AD4 +AD4 +AD4 +AD4 
+AD4 +AD4 +AD4 +AD4 +AD4 On Nov 1, 2013, at 12:57, Jeff Layton +ADw-jlayton+AEA-redhat.com+AD4 wrote:
+AD4 +AD4 +AD4 +AD4 +AD4 
+AD4 +AD4 +AD4 +AD4 +AD4 +AD4 On Fri, 1 Nov 2013 16:50:00 +-0000
+AD4 +AD4 +AD4 +AD4 +AD4 +AD4 +ACI-Myklebust, Trond+ACI +ADw-Trond.Myklebust+AEA-netapp.com+AD4 wrote:
+AD4 +AD4 +AD4 +AD4 +AD4 +AD4 
+AD4 +AD4 +AD4 +AD4 +AD4 +AD4APg On Fri, 2013-11-01 at 12:02 -0400, Jeff Layton wrote:
+AD4 +AD4 +AD4 +AD4 +AD4 +AD4APgA+ It looks like +AF8-nfs4+AF8-get+AF8-security+AF8-label() has the same problem, but I've
+AD4 +AD4 +AD4 +AD4 +AD4 +AD4APgA+ so far been unable to get it to be called, so I didn't patch it. It
+AD4 +AD4 +AD4 +AD4 +AD4 +AD4APgA+ seems like getxattr does some special stuff for SELinux labels that
+AD4 +AD4 +AD4 +AD4 +AD4 +AD4APgA+ cause them only to ever be fetched once.
+AD4 +AD4 +AD4 +AD4 +AD4 +AD4APgA+ 
+AD4 +AD4 +AD4 +AD4 +AD4 +AD4APgA+ Is there some trick to it?
+AD4 +AD4 +AD4 +AD4 +AD4 +AD4APgA+ 
+AD4 +AD4 +AD4 +AD4 +AD4 +AD4APg 
+AD4 +AD4 +AD4 +AD4 +AD4 +AD4APg Doesn't 'ls -Z' cause them to security label to be read again?
+AD4 +AD4 +AD4 +AD4 +AD4 +AD4APg 
+AD4 +AD4 +AD4 +AD4 +AD4 +AD4 
+AD4 +AD4 +AD4 +AD4 +AD4 +AD4 As best I can tell, security labels are set on the inode when the inode
+AD4 +AD4 +AD4 +AD4 +AD4 +AD4 is instantiated, and then are reset on changes (i.e. setxattr). If
+AD4 +AD4 +AD4 +AD4 +AD4 
+AD4 +AD4 +AD4 +AD4 +AD4 +ICY-and on getxattr, afaics.
+AD4 +AD4 +AD4 +AD4 +AD4 
+AD4 +AD4 +AD4 +AD4 
+AD4 +AD4 +AD4 +AD4 I don't see that. The call chain is something like this:
+AD4 +AD4 +AD4 +AD4 
+AD4 +AD4 +AD4 +AD4 vfs+AF8-getxattr
+AD4 +AD4 +AD4 +AD4   xattr+AF8-getsecurity
+AD4 +AD4 +AD4 +AD4     security+AF8-inode+AF8-getsecurity
+AD4 +AD4 +AD4 +AD4        selinux+AF8-inode+AF8-getsecurity
+AD4 +AD4 +AD4 +AD4 
+AD4 +AD4 +AD4 +AD4 ...and that function looks like it just converts the current security
+AD4 +AD4 +AD4 +AD4 context on the inode to text and plops that into the buffer.
+AD4 +AD4 +AD4 
+AD4 +AD4 +AD4 Ah, you're right. You have to turn off SELinux in order to hit
+AD4 +AD4 +AD4 nfs4+AF8-xattr+AF8-get+AF8-nfs4+AF8-label.
+AD4 +AD4 +AD4 
+AD4 +AD4 +AD4 +AD4 +AD4 +AD4 another client changes the label though, it's not clear to me how your
+AD4 +AD4 +AD4 +AD4 +AD4 +AD4 client would ever notice it until the inode is dropped from the cache.
+AD4 +AD4 +AD4 +AD4 +AD4 +AD4 
+AD4 +AD4 +AD4 +AD4 +AD4 +AD4 ISTR Eric Paris explaining to me that they do that for performance
+AD4 +AD4 +AD4 +AD4 +AD4 +AD4 reasons but it seems like something that needs to be reconsidered in
+AD4 +AD4 +AD4 +AD4 +AD4 +AD4 light of labeled NFS. Not picking up a security label change seems like
+AD4 +AD4 +AD4 +AD4 +AD4 +AD4 a bug, IMO...
+AD4 +AD4 +AD4 +AD4 +AD4 
+AD4 +AD4 +AD4 +AD4 +AD4 To be effective, the security label should normally be set at file creation time. It should rarely, if ever, change. Why would you need to change it from a different client?
+AD4 +AD4 +AD4 +AD4 +AD4 
+AD4 +AD4 +AD4 +AD4 
+AD4 +AD4 +AD4 +AD4 At least in Fedora, there are SELinux policy changes all the time.
+AD4 +AD4 +AD4 +AD4 Sometimes that involves changing how files are labeled. I don't think
+AD4 +AD4 +AD4 +AD4 it's reasonable to assume that they only get set at creation time.
+AD4 +AD4 +AD4 +AD4 
+AD4 +AD4 +AD4 
+AD4 +AD4 +AD4 That doesn't answer the question. Again, why would you need to do this
+AD4 +AD4 +AD4 from another client? If you don't have a real-life use case, then it's
+AD4 +AD4 +AD4 just another 'doctor it hurts' problem. Stop doing it...
+AD4 +AD4 +AD4 
+AD4 +AD4 
+AD4 +AD4 Ok, how about this then: +ADs)
+AD4 +AD4 
+AD4 +AD4 NFS doesn't have O+AF8-TMPFILE, so you really +ACo-can't+ACo set the context at
+AD4 +AD4 creation time, at least with normal syscalls. There will always be a
+AD4 +AD4 race window between creating a file and setting the SELinux context on
+AD4 +AD4 it.
+AD4 
+AD4 Ummm. This is supposed to be a security feature. How can you tolerate race windows?
+AD4 
+AD4 IOW: If I get the security label +ACI-wrong+ACI on lookup due to such a race,
+AD4 then how am I supposed to know not to act on it?
+AD4 
+AD4 +AD4 FWIW, I just started playing with this stuff and this behavior just
+AD4 +AD4 gave me pause. This is the sort of thing that will give people fits
+AD4 +AD4 since it's unexpected behavior.
+AD4 +AD4 
+AD4 +AD4 When I change something on the server, I typically expect the client to
+AD4 +AD4 see that change in a timely fashion. As it stands now, it won't -- at
+AD4 +AD4 least until the inode gets purged from the cache.
+AD4 
+AD4 See my previous answer: don't do that... If you want a different answer,
+AD4 then feel free to propose a caching model, but note that it's going to
+AD4 be very hard to deal sensibly with your race condition above. That's the
+AD4 reason why we went with the current caching model.
+AD4 

I think we may be misunderstanding one another.

I'm not suggesting that we need to always fetch the label before any
use of an inode. The problem I was seeing is similar to what Dave
mentioned a month or so ago. Even in the case where we are fetching a
security label, we aren't always applying it to the inode.

The red flag for me is that we are calling nfs+AF8-setsecurity on existing
inodes in nfs+AF8-prime+AF8-dcache, but aren't calling it in
+AF8AXw-nfs+AF8-revalidate+AF8-inode. That's why 'ls -Z' works to make the client
pick up the label change when the parent directory changes, but 'stat'
doesn't.

I've just sent a patch that seems to fix the behavior for me in most
cases. Does it look reasonable?

-- 
Jeff Layton +ADw-jlayton+AEA-redhat.com+AD4
