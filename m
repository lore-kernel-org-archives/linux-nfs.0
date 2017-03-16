Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f50.google.com ([209.85.214.50]:36698 "EHLO
        mail-it0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753913AbdCPSZP (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Mar 2017 14:25:15 -0400
Received: by mail-it0-f50.google.com with SMTP id w124so79890911itb.1
        for <linux-nfs@vger.kernel.org>; Thu, 16 Mar 2017 11:25:10 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: software error with bugzilla.linux-nfs.org
From: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <1489688316.11936.2.camel@primarydata.com>
Date: Thu, 16 Mar 2017 14:23:45 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <0479196B-5B07-4836-B7F9-65064D98E32E@gmail.com>
References: <1BF99BE7-DE8A-436B-B5A7-9080D9E9AC93@gmail.com> <1489688316.11936.2.camel@primarydata.com>
To: Trond Myklebust <trondmy@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Mar 16, 2017, at 2:18 PM, Trond Myklebust <trondmy@primarydata.com> =
wrote:
>=20
> On Thu, 2017-03-16 at 13:59 -0400, Chuck Lever wrote:
>> When I tried to add a comment to bug 291, this resulted:
>>=20
>> DBD::mysql::db do failed: Incorrect key file for table
>> './nfsv4_bugzilla/bugs_fulltext.MYI'; try to repair it [for Statement
>> "UPDATE bugs_fulltext SET comments =3D ?, comments_noprivate =3D ?
>> =E8=81=BD=E8=81=BD=E8=81=BD=E8=81=BD=E8=81=BD=E8=81=BD=E8=81=BD=E8=81=BD=
=E8=81=BD=E8=81=BD=E8=81=BD=E8=81=BD=E8=81=BD=E8=81=BD=E8=81=BDWHERE =
bug_id =3D ?"] at Bugzilla/Bug.pm line 938.
>> 	Bugzilla::Bug::_sync_fulltext(Bugzilla::Bug=3DHASH(0x3a1a278))
>> called at Bugzilla/Bug.pm line 886
>> 	Bugzilla::Bug::update(Bugzilla::Bug=3DHASH(0x3a1a278), "2017-03-
>> 16 10:58:16") called at /home/linux-
>> nfs.org/nfsv4_bugzilla/process_bug.cgi line 547
>>=20
>> Happened twice out of two attempts.
>=20
> The backing mariadb database needed repair following a crash. I'm
> hoping it is working now. Can you please retry?

Still not working. I guess this looks like the same error message.

DBD::mysql::db do failed: Incorrect key file for table =
'./nfsv4_bugzilla/bugs_fulltext.MYI'; try to repair it [for Statement =
"UPDATE bugs_fulltext SET comments =3D ?, comments_noprivate =3D ?
               WHERE bug_id =3D ?"] at Bugzilla/Bug.pm line 938.
	Bugzilla::Bug::_sync_fulltext(Bugzilla::Bug=3DHASH(0x421c4d8)) =
called at Bugzilla/Bug.pm line 886
	Bugzilla::Bug::update(Bugzilla::Bug=3DHASH(0x421c4d8), =
"2017-03-16 11:22:07") called at =
/home/linux-nfs.org/nfsv4_bugzilla/process_bug.cgi line 547


--
Chuck Lever
chucklever@gmail.com



