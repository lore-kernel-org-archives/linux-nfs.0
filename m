Return-Path: <SRS0=Htud=OG=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 45C76C43441
	for <linux-nfs@archiver.kernel.org>; Tue, 27 Nov 2018 23:20:44 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0F25320873
	for <linux-nfs@archiver.kernel.org>; Tue, 27 Nov 2018 23:20:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0F25320873
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726354AbeK1KUM (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 28 Nov 2018 05:20:12 -0500
Received: from mx2.suse.de ([195.135.220.15]:35994 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726068AbeK1KUM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 28 Nov 2018 05:20:12 -0500
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay1.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id E13E4B05E;
        Tue, 27 Nov 2018 23:20:40 +0000 (UTC)
From:   NeilBrown <neilb@suse.com>
To:     "J. Bruce Fields" <bfields@redhat.com>,
        kernel test robot <rong.a.chen@intel.com>
Date:   Wed, 28 Nov 2018 10:20:34 +1100
Cc:     Jeff Layton <jlayton@kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Jeff Layton <jlayton@redhat.com>, lkp@01.org,
        linux-nfs@vger.kernel.org
Subject: Re: [LKP] [fs/locks]  83b381078b:  will-it-scale.per_thread_ops -62.5% regression
In-Reply-To: <20181127174315.GA29963@parsley.fieldses.org>
References: <20181127060102.GF6163@shao2-debian> <20181127174315.GA29963@parsley.fieldses.org>
Message-ID: <87mupup0ot.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, Nov 27 2018, J. Bruce Fields wrote:

> Thanks for the report!

Yes, thanks.  I thought I had replied to the previous report of a similar
problem, but I didn't actually send that email - oops.
Though the test is the same and the regression similar, this is a
different patch.  The previous report identified=20
 fs/locks: allow a lock request to block other requests
this one identifies
  fs/locks: always delete_block after waiting.

Both cause blocked_lock_lock to be taken more often.

In one case is it due to locks_move_blocks().  That can probably be
optimised to skip the lock if list_empty(&fl->fl_blocked_requests).
I'd need to double-check, but I think that is safe to check without
locking.

This one causes locks_delete_blocks() to be called more often.  We now
call it even if no waiting happened at all.  I suspect we can test for
that and avoid it.  I'll have a look.

>
> On Tue, Nov 27, 2018 at 02:01:02PM +0800, kernel test robot wrote:
>> FYI, we noticed a -62.5% regression of will-it-scale.per_thread_ops due =
to commit:
>>=20
>>=20
>> commit: 83b381078b5ecab098ebf6bc9548bb32af1dbf31 ("fs/locks: always dele=
te_block after waiting.")
>> https://git.kernel.org/cgit/linux/kernel/git/jlayton/linux.git locks-next
>>=20
>> in testcase: will-it-scale
>> on test machine: 88 threads Intel(R) Xeon(R) CPU E5-2699 v4 @ 2.20GHz wi=
th 64G memory
>> with following parameters:
>>=20
>> 	nr_task: 16
>> 	mode: thread
>> 	test: lock1
>
> So I guess it's doing this, uncontended file lock/unlock?:
>
> 	https://github.com/antonblanchard/will-it-scale/blob/master/tests/lock1.c
>
> Each thread is repeatedly locking and unlocking a file that is only used
> by that thread.

Thanks for identifying that Bruce.
This would certainly be a case where locks_delete_block() is now being
called when it wasn't before.


>
> By the way, what's the X-axis on these graphs?  (Or the y-axis, for that
> matter?)

A key would help.  I think the X-axis is number-of-threads.  y-axis
might be ops-per-second ??.

Thanks,
NeilBrown


>
> --b.
>
>>                             will-it-scale.per_thread_ops=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20
>>=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20
>>   450000 +-+------------------------------------------------------------=
----+=20=20=20
>>          |                                                              =
    |=20=20=20
>>   400000 +-+   +..+..  .+..+..  .+..+..+...+..+..+..   +..        .+..  =
  ..|=20=20=20
>>   350000 +-+ ..      +.       +.                     ..         +.    +.=
.+  |=20=20=20
>>          |  +                                       +     +     :       =
    |=20=20=20
>>   300000 +-+                                              :    :        =
    |=20=20=20
>>   250000 +-+                                               :   :        =
    |=20=20=20
>>          |                                                 :   :        =
    |=20=20=20
>>   200000 +-+                                               :   :        =
    |=20=20=20
>>   150000 +-+                                                : :         =
    |=20=20=20
>>          O  O  O  O  O  O  O  O  O  O  O   O  O  O  O  O  O :O: O  O  O =
 O  O=20=20=20
>>   100000 +-+                                                : :         =
    |=20=20=20
>>    50000 +-+                                                : :         =
    |=20=20=20
>>          |                                                   :          =
    |=20=20=20
>>        0 +-+------------------------------------------------------------=
----+=20=20=20
>>=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20
>>=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20
>>                                will-it-scale.workload=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20
>>=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20
>>   7e+06 +-+-------------------------------------------------------------=
----+=20=20=20
>>         |              +...+..           .+..+..+     +            +..  =
    |=20=20=20
>>   6e+06 +-+   +..+.. ..         .+..+..+.        +   + +         ..     =
  ..|=20=20=20
>>         |   ..      +         +.                  + +   +       +     +.=
.+  |=20=20=20
>>   5e+06 +-++                                       +     +      :       =
    |=20=20=20
>>         |                                                :     :        =
    |=20=20=20
>>   4e+06 +-+                                               :    :        =
    |=20=20=20
>>         |                                                 :    :        =
    |=20=20=20
>>   3e+06 +-+                                                :   :        =
    |=20=20=20
>>         |                                       O     O    :  : O  O    =
    |=20=20=20
>>   2e+06 O-+O  O  O  O  O   O  O  O  O  O  O  O     O     O : O:       O =
 O  O=20=20=20
>>         |                                                   : :         =
    |=20=20=20
>>   1e+06 +-+                                                 : :         =
    |=20=20=20
>>         |                                                    :          =
    |=20=20=20
>>       0 +-+-------------------------------------------------------------=
----+=20=20=20
>>=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20
>>=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20
>>                            will-it-scale.time.user_time=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20
>>=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20
>>   250 +-+---------------------------------------------------------------=
----+=20=20=20
>>       |                 .+..               .+..                   +..   =
    |=20=20=20
>>       |..   +...+..  .+.      .+...+..+..+.    +..    +..       ..   .  =
  ..|=20=20=20
>>   200 +-+ ..       +.       +.                    . ..         +      +.=
.+  |=20=20=20
>>       |  +                                         +     +     :        =
    |=20=20=20
>>       |                                                  :    :         =
    |=20=20=20
>>   150 +-+                                                 :   :         =
    |=20=20=20
>>       |                                                   :   :         =
    |=20=20=20
>>   100 +-+                                                 :   :         =
    |=20=20=20
>>       |  O      O                                          : :          =
    |=20=20=20
>>       O     O      O  O  O  O  O   O  O  O  O  O   O  O  O :O: O  O   O =
 O  O=20=20=20
>>    50 +-+                                                  : :          =
    |=20=20=20
>>       |                                                    : :          =
    |=20=20=20
>>       |                                                     :           =
    |=20=20=20
>>     0 +-+---------------------------------------------------------------=
----+=20=20=20
>>=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20
>>=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20
>>                           will-it-scale.time.system_time=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20
>>=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20
>>   5000 +-+--------------------------------------------------------------=
----+=20=20=20
>>   4500 O-+O..O..O...O..O..O..O..O..O..O...O..O..O..O..O..O  O  O...O..O.=
.O..O=20=20=20
>>        |                                                 :     :        =
    |=20=20=20
>>   4000 +-+                                               :     :        =
    |=20=20=20
>>   3500 +-+                                                :   :         =
    |=20=20=20
>>        |                                                  :   :         =
    |=20=20=20
>>   3000 +-+                                                :   :         =
    |=20=20=20
>>   2500 +-+                                                :   :         =
    |=20=20=20
>>   2000 +-+                                                 : :          =
    |=20=20=20
>>        |                                                   : :          =
    |=20=20=20
>>   1500 +-+                                                 : :          =
    |=20=20=20
>>   1000 +-+                                                 : :          =
    |=20=20=20
>>        |                                                    :           =
    |=20=20=20
>>    500 +-+                                                  :           =
    |=20=20=20
>>      0 +-+--------------------------------------------------------------=
----+=20=20=20
>>=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20
>>=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=20=
=20=20=20=20=20=20=20
>> [*] bisect-good sample
>> [O] bisect-bad  sample

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlv90UIACgkQOeye3VZi
gbnQiw//dlZQTtoolVqtfDTeStauX3I/+zJGPFjBd80aha39eeFhrDrYnPK0FEXA
HihxxOMWFfDbGccXXmeDKcuGu4+TZbfXquGOVwKFz9cF9OKbUbQj/6vdk7MMBtEK
q7/SBJ+CvEittcOXaC5GWbszTnO9PH01/9ebIkNOOyo/Lx0lALqmgmGCRUTLmoyS
/pHqsVULokqfBycpY4qvEuH8vsfNHxEYAm4nHEkDfBzawsNWGXWGwc/wsdyzd/QD
FLIA9M9aqq6grzJE/4FThu89kCe1jNiVce/m3FLo9MjvK2xnqFQ8Y7auslMpzz9U
m827k+EhQOF1erkz9LCOeIT4LPOTUxF/JwiazEWts4UlnB3yacPnnji2ZSe+qi2r
11+NRCzQLPLym3rErox0BKBDYIfFCyASMM8xY/DTYAt/x1IVwaloImhyHTRTCrTO
8FqcXbU8Q0HTCmJxVoe98/IRIdQgDZm/u6VxAmLU5P6mq78NtVBRMtSi2Mt1RqXB
WHyv4mmfiZUCbnjFk1+wNbqL2XQndBGrk/R29PAEF7zA7xvabvFiTmUTyH3SFtDB
5xUiZCRbbHPPDOgUC7NUzJmVaHCuYeRKiVXL5ruqXkNvyFjcgLUqwDWm2QwIc4ex
IPX3eI3sR5IKIRgvGkPiJ7x/GJop5BtxRTuA6haLHqXBtFL/ph8=
=jf//
-----END PGP SIGNATURE-----
--=-=-=--
