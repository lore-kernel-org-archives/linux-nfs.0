Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from victor.provo.novell.com ([137.65.250.26]:52486 "EHLO
	prv3-mh.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757395AbcCaWk1 (ORCPT
	<rfc822;groupwise-linux-nfs@vger.kernel.org:0:0>);
	Thu, 31 Mar 2016 18:40:27 -0400
From: NeilBrown <nfbrown@novell.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Date: Fri, 01 Apr 2016 09:40:13 +1100
Cc: Christian Robottom Reis <kiko@acm.org>,
        NFS List <linux-nfs@vger.kernel.org>
Subject: Re: Finding and breaking client locks
In-Reply-To: <CAHQdGtT+Uwj9zuX+KqB92sVjzcOChvOmr1UDN-ZMQdSURhvWwg@mail.gmail.com>
References: <20160321143914.GA6397@anthem.async.com.br> <20160322005813.GA3378@anthem.async.com.br> <87io03s0ak.fsf@notabene.neil.brown.name> <CAHQdGtT+Uwj9zuX+KqB92sVjzcOChvOmr1UDN-ZMQdSURhvWwg@mail.gmail.com>
Message-ID: <8737r6s242.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Fri, Apr 01 2016, Trond Myklebust wrote:

> On Thu, Mar 31, 2016 at 1:07 AM, NeilBrown <nfbrown@novell.com> wrote:
>>
>> On Tue, Mar 22 2016, Christian Robottom Reis wrote:
>>
>> > On Mon, Mar 21, 2016 at 11:39:14AM -0300, Christian Robottom Reis wrote:
>> >> indeed does not return any information pertaining NFS client locks, and
>> >> I'm not clear whether /proc/locks (on the server side obviously) does or
>> >> not.
>> >
>> > Somewhat OT, but I find it a PITA that /proc/locks gives inode numbers
>> > that then need to be looked up individually. I have often been surprised
>> > no tool exists to parse that and give you back a report of filenames, so
>> > I just put together a small tool that just offloads the work to debugfs.
>> >
>> > I've attached it in case others might find it useful.
>>
>> Nice idea, though it only works with extXfs - better than nothing
>> though.
>>
>> It would be really easy to do this in the kernel.
>> I would be very much in favour of a /proc/locks-extended (or whatever)
>> that provides the same information as /proc/locks, but in a format
>> which includes full path name, process name, and - for nfs locks -
>> client name etc.
>
> Why isn't the current interface sufficient? The 'lslocks' utility
> appears quite capable of extracting the full path info.
>

I don't think I've come across 'lslocks' before - thanks.
It does help a bit but when I run it, most of the "PATH" column is
empty.
Which is odd because I can fill in some of the blanks by cross
referencing pid/inode from /proc/locks with inodes numbers from
  ls -liL /proc/$PID/fd

to get full names.

Any way, you are right that more information is available if you are
willing to hunt around, but not everything.  In particular, for locks
held by lockd (or NFSv4 locks held by nfsd) it would be nice to know
which client host it was held on behalf of.

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJW/adNAAoJEDnsnt1WYoG5iLcP/1ouC8N7SOPX80XcirlPVNzg
8+1Gy4t6yLAPaOkqQ2n7+BFOCditGOBLVu61DW3r5RrmEVp7Lfg9Yvg0lWcSviK+
X0NccCCcSn91+lmAPfxHsrXgrRoImTUop/cflGMLJ5ysV8RQNKJp9dRnIFCfBp6d
dp1yLJDkopM4EDUU6/gSm4iQaWoa5sQ7dADEVxzzchDAB6v3MgFDfUki8WYRWZSf
6zzc5LN0Ib6s7V2If67kgBNk5O0lRlcTqGM956SxB9uYFnCBAD9sRbyZkH2eXkz3
wvLC9IF5cdeoq56AOxZduYe/cODgDYV0iLAXsu+ECWhR/TVqcQIMU0m9DimNsbIR
gthKAVVcLqc+pFVfK0qt2PsDuXvM1XJZyBPUJbqTyXVIsVYEByhy1d76jX7NadTf
VoUA+uXW0PtpM5457qsf+oAYK5yh0vTVmhr46ZljqATxWRvuECeBf6eyOizwVKrp
fWQQsQwF1cfZ0GZVu4GljN2Tcx0uK2mD0PW1e7MC/5ELI5mzqDLMfrV2twz1nJKn
o3kHmiTz9d9RskykqhgO6rGpl4m/6hFk7IHoYKZODnWeaYGRETDc9ew6NHCo/Tz6
oJBSN1FxQzQITZB9d3Y901n4zsM3LkNzUJhr8+VsUDYkRw2oMlu5w+kSgCVV1Ngy
42tkjd6W1CnIpHmtLL9T
=LKhP
-----END PGP SIGNATURE-----
--=-=-=--
