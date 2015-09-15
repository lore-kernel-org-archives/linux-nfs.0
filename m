Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from elasmtp-galgo.atl.sa.earthlink.net ([209.86.89.61]:35318 "EHLO
	elasmtp-galgo.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752014AbbIOU2b (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Sep 2015 16:28:31 -0400
From: "Frank Filz" <ffilzlnx@mindspring.com>
To: "'Chuck Lever'" <chuck.lever@oracle.com>
Cc: "'Linux NFS Mailing List'" <linux-nfs@vger.kernel.org>
References: <7A550B5E-9EAB-4431-BBBA-1C77EE86539F@oracle.com> <019501d0efd4$401f4240$c05dc6c0$@mindspring.com> <E19B018D-1578-4964-B29F-FC7BF361F977@oracle.com> <01a301d0efdd$b8106f00$28314d00$@mindspring.com> <242A24C3-0D5F-4181-9E99-E8E9EDE12190@oracle.com> <01ae01d0efe6$bac7d7c0$30578740$@mindspring.com> <F892EE47-F039-47BE-BE3D-4551F91A665B@oracle.com>
In-Reply-To: <F892EE47-F039-47BE-BE3D-4551F91A665B@oracle.com>
Subject: RE: NFSv4 security negotiation issue
Date: Tue, 15 Sep 2015 13:28:18 -0700
Message-ID: <01bf01d0eff5$0f6a11e0$2e3e35a0$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> >> On Sep 15, 2015, at 1:41 PM, Frank Filz <ffilzlnx@mindspring.com>
wrote:
> >>
> >>>> There are two shares on the server.
> >>>>
> >>>> The share being mounted is /export/CTHON. It is a sys-only share.
> >>>> No
> >>> "sec="
> >>>> option is used on the mount command. The expected outcome is that
> >>>> the mount will succeed and use sec=sys.
> >>>>
> >>>> The share that is not being mounted here is /export/KRB5.
> >>>> It is shared with at least krb5i, which means the set of flavors
> >>>> the
> >>> server
> >>>> accepts for the pseudofs includes both krb5i and sys.
> >>>>
> >>>> The client has already negotiated krb5i to access the pseudofs. I
> >>>> see a PUTROOTFH using krb5i and it is successful. The negotiation
> >>>> is not in the
> >>> trace
> >>>> I have.
> >>>>
> >>>> I see a number of GETATTRs then a LOOKUP /export, all with krb5i,
> >>>> all successful.
> >>>>
> >>>> Using krb5i, LOOKUP /CTHON, which fails with WRONGSEC.
> >>>>
> >>>> Client recovers with SECINFO on /CTHON using krb5i. The server
> >>>> responds with a list containing just AUTH_UNIX.
> >>>>
> >>>> Client tries the LOOKUP /CTHON again, now with sys. It works.
> >>>>
> >>>> Similar GETATTR activity using sys as the client mounts this share.
> >>>>
> >>>> Then one last GETATTR, this time using krb5i. The FH is the
> >>>> /export/CTHON directory. This fails with WRONGSEC.
> >>>>
> >>>> The attr mask here is Supported Attrs, FH_Expire_type,
> >>>> Link_Support, Symlink_Support, ACLSupport. This is from
> >>>> nfs4_server_capabilities(),
> >>> which
> >>>> is invoked only in nfs4_proc_get_rootfh() and nfs4_proc_get_root().
> >>>>
> >>>> The next operation OTW is a RENEW that happens a minute later.
> >>>
> >>> From that sequence, I'm pretty sure we want to fix this in the
> >>> client not the server.
> >>>
> >>> Hmm, did fsid change?
> >>
> >> I'm not sure how to tell. The working LOOKUP operations on
> >> parent/CTHON always return the same FSID.
> >
> > I should have been more clear... Is the fsid for /export different
> > from the fsid for /export/CTHON? If it changes that should produce a new
> superblock.
> 
> The PUTROOTFH, GETATTR reply returns an FSID of
> 
> fsid4.major = 13172185619750249631
> fsid4.minor = 0
> 
> The LOOKUP reply for /export returns an FSID of
> 
> fsid4.major = 5354380871752655416
> fsid4.minor = 0
> 
> The LOOKUP reply for /export/CTHON returns an FSID of
> 
> fsid4.major = 5354380871752655416
> fsid4.minor = 0
> 
> But I thought the security policy boundaries on the server did not have to
> correspond with FSID boundaries.

I think that's a reasonable expectation, though of course there's no
guarantee filehandle guessing couldn't be used to access files in a
different portion of the filesystem.

> > Does the mount work if sec=sys is specified?
> >>
> >> Yes.
> >
> > And with different mount options, a different superblock should
> > definitely be created.
> >
> > I wonder if there is some way we can push up the security negotiation
> > to help identify a new superblock is necessary, equivalent to having a
> > different mount option?
> 
> The question, to me, is whether the client should use the correct security
> flavor for the share right off the bat (because the server has told it to
use sys
> already), or whether it should try to recover from the second WRONGSEC
> instead of failing.

I think the problem you are having is that the client is trying to re-use
the superblock because FSID and mount options are the same. The problem is
since the security policy is different, a second superblock is required in
this case. When security flavor is specified on mount, that forces a
different superblock because of the difference in mount options.

I think it should use the correct flavor, but maybe recovery from the
WRONGSEC is a path to creating a different superblock in this case?

Hmm, I think my original security negotiation testing might have been before
we added superblock sharing (back in 2006, and really mostly on RHEL 5 as my
testing was primarily in service of backporting security negotiation to RHEL
5), so I might not have run into this issue even if I had a test that would
trip over it now...

Frank


---
This email has been checked for viruses by Avast antivirus software.
https://www.avast.com/antivirus

