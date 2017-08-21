Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:34971 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750985AbdHUGXz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 21 Aug 2017 02:23:55 -0400
From: NeilBrown <neilb@suse.com>
To: Ian Kent <ikent@redhat.com>, Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trondmy@primarydata.com>,
        "viro\@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>
Date: Mon, 21 Aug 2017 16:23:42 +1000
Cc: "linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "mkoutny\@suse.com" <mkoutny@suse.com>,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel\@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        David Howells <dhowells@redhat.com>
Subject: Re: Do we really need d_weak_revalidate???
In-Reply-To: <2e289bba-677b-cc50-5fa3-2d24d1f6b858@redhat.com>
References: <87bmnmrai9.fsf@notabene.neil.brown.name> <1502430944.3822.1.camel@primarydata.com> <1502449309.4950.2.camel@redhat.com> <87zib3niqn.fsf@notabene.neil.brown.name> <1502705432.4978.1.camel@redhat.com> <877ey4nsep.fsf@notabene.neil.brown.name> <1502883253.4847.6.camel@redhat.com> <1e4665a6-30d6-c16a-760a-2892fb147760@redhat.com> <878tihmora.fsf@notabene.neil.brown.name> <2e289bba-677b-cc50-5fa3-2d24d1f6b858@redhat.com>
Message-ID: <87h8x1l9qp.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, Aug 18 2017, Ian Kent wrote:

> On 18/08/17 13:24, NeilBrown wrote:
>> On Thu, Aug 17 2017, Ian Kent wrote:
>>=20
>>> On 16/08/17 19:34, Jeff Layton wrote:
>>>> On Wed, 2017-08-16 at 12:43 +1000, NeilBrown wrote:
>>>>> On Mon, Aug 14 2017, Jeff Layton wrote:
>>>>>
>>>>>> On Mon, 2017-08-14 at 09:36 +1000, NeilBrown wrote:
>>>>>>> On Fri, Aug 11 2017, Jeff Layton wrote:
>>>>>>>
>>>>>>>> On Fri, 2017-08-11 at 05:55 +0000, Trond Myklebust wrote:
>>>>>>>>> On Fri, 2017-08-11 at 14:31 +1000, NeilBrown wrote:
>>>>>>>>>> Funny story.  4.5 years ago we discarded the FS_REVAL_DOT superb=
lock
>>>>>>>>>> flag and introduced the d_weak_revalidate dentry operation inste=
ad.
>>>>>>>>>> We duly removed the flag from NFS superblocks and NFSv4 superblo=
cks,
>>>>>>>>>> and added the new dentry operation to NFS dentries .... but not =
to
>>>>>>>>>> NFSv4
>>>>>>>>>> dentries.
>>>>>>>>>>
>>>>>>>>>> And nobody noticed.
>>>>>>>>>>
>>>>>>>>>> Until today.
>>>>>>>>>>
>>>>>>>>>> A customer reports a situation where mount(....,MS_REMOUNT,..) o=
n an
>>>>>>>>>> NFS
>>>>>>>>>> filesystem hangs because the network has been deconfigured.  This
>>>>>>>>>> makes
>>>>>>>>>> perfect sense and I suggested a code change to fix the problem.
>>>>>>>>>> However when a colleague was trying to reproduce the problem to
>>>>>>>>>> validate
>>>>>>>>>> the fix, he couldn't.  Then nor could I.
>>>>>>>>>>
>>>>>>>>>> The problem is trivially reproducible with NFSv3, and not at all=
 with
>>>>>>>>>> NFSv4.  The reason is the missing d_weak_revalidate.
>>>>>>>>>>
>>>>>>>>>> We could simply add d_weak_revalidate for NFSv4, but given that =
it
>>>>>>>>>> has been missing for 4.5 years, and the only time anyone noticed=
 was
>>>>>>>>>> when the ommission resulted in a better user experience, I do wo=
nder
>>>>>>>>>> if
>>>>>>>>>> we need to.  Can we just discard d_weak_revalidate?  What purpose
>>>>>>>>>> does
>>>>>>>>>> it serve?  I couldn't find one.
>>>>>>>>>>
>>>>>>>>>> Thanks,
>>>>>>>>>> NeilBrown
>>>>>>>>>>
>>>>>>>>>> For reference, see
>>>>>>>>>> Commit: ecf3d1f1aa74 ("vfs: kill FS_REVAL_DOT by adding a
>>>>>>>>>> d_weak_revalidate dentry op")
>>>>>>>>>>
>>>>>>>>>>
>>>>>>>>>>
>>>>>>>>>> To reproduce the problem at home, on a system that uses systemd:
>>>>>>>>>> 1/ place (or find) a filesystem image in a file on an NFS filesy=
stem.
>>>>>>>>>> 2/ mount the nfs filesystem with "noac" - choose v3 or v4
>>>>>>>>>> 3/ loop-mount the filesystem image read-only somewhere
>>>>>>>>>> 4/ reboot
>>>>>>>>>>
>>>>>>>>>> If you choose v4, the reboot will succeed, possibly after a 90se=
cond
>>>>>>>>>> timeout.
>>>>>>>>>> If you choose v3, the reboot will hang indefinitely in systemd-
>>>>>>>>>> shutdown while
>>>>>>>>>> remounting the nfs filesystem read-only.
>>>>>>>>>>
>>>>>>>>>> If you don't use "noac" it can still hang, but only if something
>>>>>>>>>> slows
>>>>>>>>>> down the reboot enough that attributes have timed out by the time
>>>>>>>>>> that
>>>>>>>>>> systemd-shutdown runs.  This happens for our customer.
>>>>>>>>>>
>>>>>>>>>> If the loop-mounted filesystem is not read-only, you get other
>>>>>>>>>> problems.
>>>>>>>>>>
>>>>>>>>>> We really want systemd to figure out that the loop-mount needs t=
o be
>>>>>>>>>> unmounted first.  I have ideas concerning that, but it is messy.=
  But
>>>>>>>>>> that isn't the only bug here.
>>>>>>>>>
>>>>>>>>> The main purpose of d_weak_revalidate() was to catch the issues t=
hat
>>>>>>>>> arise when someone changes the contents of the current working
>>>>>>>>> directory or its parent on the server. Since '.' and '..' are tre=
ated
>>>>>>>>> specially in the lookup code, they would not be revalidated witho=
ut
>>>>>>>>> special treatment. That leads to issues when looking up files as
>>>>>>>>> ./<filename> or ../<filename>, since the client won't detect that=
 its
>>>>>>>>> dcache is stale until it tries to use the cached dentry+inode.
>>>>>>>>>
>>>>>>>>> The one thing that has changed since its introduction is, I belie=
ve,
>>>>>>>>> the ESTALE handling in the VFS layer. That might fix a lot of the
>>>>>>>>> dcache lookup bugs that were previously handled by d_weak_revalid=
ate().
>>>>>>>>> I haven't done an audit to figure out if it actually can handle a=
ll of
>>>>>>>>> them.
>>>>>>>>>
>>>>>>>>
>>>>>>>> It may also be related to 8033426e6bdb2690d302872ac1e1fadaec1a5581:
>>>>>>>>
>>>>>>>>     vfs: allow umount to handle mountpoints without revalidating t=
hem
>>>>>>>
>>>>>>> You say in the comment for that commit:
>>>>>>>
>>>>>>>      but there
>>>>>>>     are cases where we do want to revalidate the root of the fs.
>>>>>>>
>>>>>>> Do you happen to remember what those cases are?
>>>>>>>
>>>>>>
>>>>>> Not exactly, but I _think_ I might have been assuming that we needed=
 to
>>>>>> ensure that the inode attrs on the root were up to date after the
>>>>>> pathwalk.
>>>>>>
>>>>>> I think that was probably wrong. d_revalidate is really intended to
>>>>>> ensure that the dentry in question still points to the same inode. In
>>>>>> the case of the root of the mount though, we don't really care about=
 the
>>>>>> dentry on the server at all. We're attaching the root of the mount t=
o an
>>>>>> inode and don't care of the dentry name changes. If we do need to en=
sure
>>>>>> the inode attrs are updated, we'll just revalidate them at that poin=
t.
>>>>>>
>>>>>>>>
>>>>>>>> Possibly the fact that we no longer try to revalidate during unmou=
nt
>>>>>>>> means that this is no longer necessary?
>>>>>>>>
>>>>>>>> The original patch that added d_weak_revalidate had a reproducer i=
n the
>>>>>>>> patch description. Have you verified that that problem is still not
>>>>>>>> reproducible when you remove d_weak_revalidate?
>>>>>>>
>>>>>>> I did try the reproducer and it works as expected both with and wit=
hout
>>>>>>> d_weak_revalidate.
>>>>>>> On reflection, the problem it displayed was caused by d_revalidate()
>>>>>>> being called when the dentry name was irrelevant.  We remove that
>>>>>>> (fixing the problem) and introduce d_weak_revalidate because we tho=
ught
>>>>>>> that minimum functionality was still useful.  I'm currently not
>>>>>>> convinced that even that is needed.
>>>>>>>
>>>>>>> If we discarded d_weak_revalidate(), we could get rid of the special
>>>>>>> handling of umount....
>>>>>>
>>>>>> I like idea. I say go for it and we can see what (if anything) break=
s?
>>>>>
>>>>> Getting rid of d_weak_revalidate is easy enough - hardly any users.
>>>>>
>>>>> Getting rid of filename_mountpoint() isn't so easy unfortunately.
>>>>> autofs4 uses kern_path_mountpoint() - presumably to avoid getting stu=
ck
>>>>> in autofs4_d_manage()?  It would be a shame to keep this infrastructu=
re
>>>>> around just so that one part of autofs4 can talk to another part of
>>>>> autofs4.
>>>
>>> When this was first implemented autofs didn't use kern_path_mountpoint()
>>> (it didn't exist) it used a path lookup on the parent and a separate
>>> lookup for the last component.
>>=20
>> This was before commit 4e44b6852e03 ("Get rid of path_lookup in
>> autofs4").  This used kern_path().
>
> I have to plead not guilty of this one.
>
> IIRC it broke the requirement of "lookup parent then lookup last componen=
t"
> rather it walked the whole path then followed up to find the mount point
> struct path.
>
> Like it says in the description of ac8387199656 the caller might not yet
> "own" the autofs mount which causes a mount to be triggered during the
> walk that can't be satisfied because of the deadlock that occurs.

A mount isn't triggered by kern_path(pathname, 0, &path).
That '0' would need to include one of
  LOOKUP_PARENT | LOOKUP_DIRECTORY |
  LOOKUP_OPEN | LOOKUP_CREATE | LOOKUP_AUTOMOUNT

to trigger an automount (otherwise you just get -EISDIR).

That is why I assumed that ->d_managed was the problem.

>
>>=20
>> I'm more interested in commit ac8387199656 ("autofs4 - fix device ioctl
>> mount lookup")  which replaced the use of kern_path() with
>> kern_path_mountpoint().
>
> Probably should have had a Fixes: 4e44b6852e03 ...

Still a bit confused as to exactly what was fixed...

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlmafHEACgkQOeye3VZi
gbnsmA/+JLcj8VaZH5hOJeXbtwbnqmCDcYLMFVclUXmVdAxGRocTKX1F3ENJvFK/
cahannWJ1EPEp4Rc1boEjSWQYmT+jezAXO2qkU6N25Tr3C0KniKsL0tId4F7385H
n03D8vKcscNQBNufFDiyhdRtH4NvQOGvhZYKEsT5BTfMs1tR9scvOfvFK1+dhFki
qfvlNurfKVrVonmiKi9sa3aJwCQezycVGc7PwJw4ET5JxWc4yPXkcoFdTZeezikZ
Es6QPY62/7yNllBZznGsuTf9U4CSrIe1WMxZbUlx4yE9uyk5Vwb+napEnI9I9W0z
ZbrXK4gF9ou3EXmtCqKSb4RIUEDKAFTXJ0Ckbp+PazX58wK54eN4eObfLsZWUqQF
1AoQ0zriU9rao12grlWYDSON6aF7ybHB8X/k/+kYeNw1jof9yHwP/vtjMcLn3iu3
MHW8TSox6wdta2xhZ4sbmFtKftNRzCQ6w9c3nM15frUd3PsqgOeKpcvkhXfIQKHa
0Q0mW9OvsUUcrZ+8+TRshAKF9Fne9FoMLAw2izHY363ZOMhU0dTJ5yxGKuOjRAWe
chxjh/kEVv3abOhTnMPPbl1OpzeAgtWi02r+qbp4UEjiyWHSgr5X0pf2kZc5Bii4
qcv5eqAn5DpAvcx8HGPErkTOjKE3uP6g2ISEaiwwKJMgr7PI0Mg=
=iyvo
-----END PGP SIGNATURE-----
--=-=-=--
