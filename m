Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:30221 "HELO
	discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752291AbbLIORj convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Dec 2015 09:17:39 -0500
From: Andrew W Elble <aweits@rit.edu>
To: Weston Andros Adamson <dros@primarydata.com>
Cc: linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH RFC 0/4] Deal with lost delegations and EKEYEXPIRED
References: <1449067193-53310-1-git-send-email-aweits@rit.edu>
	<38076235-99FC-4CC7-8F16-3518A58CABA2@primarydata.com>
Date: Wed, 09 Dec 2015 09:17:38 -0500
In-Reply-To: <38076235-99FC-4CC7-8F16-3518A58CABA2@primarydata.com> (Weston
	Andros Adamson's message of "Tue, 08 Dec 2015 16:38:22 -0500")
Message-ID: <m2bn9zwvst.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> One part I’m not sure about is in nfsd4_spo_must_allow dealing with putfh like
> ops vs not putfh-like ops. I’ll have to check the spec and take a deeper look at
> that when I get some time, but maybe a brief explanation in a comment would
> help?

Will put on the list for v2.

RFC5561 2.6.3.1.1.7:
   The NFSv4.1 server MUST NOT return NFS4ERR_WRONGSEC to any operation
   other than a put filehandle operation, LOOKUP, LOOKUPP, and OPEN (by
   component name).

RFC5561 15.4:
   | NFS4ERR_WRONGSEC                  | LINK, LOOKUP, LOOKUPP, OPEN,  |
   |                                   | PUTFH, PUTPUBFH, PUTROOTFH,   |
   |                                   | RENAME, RESTOREFH

See need_wrongsec_check() (called from nfsd4_proc_compound()).

The implementation problem is that fh_verify() also calls check_nfsd_access(),
so these contortions are to avoid sending NFS4ERR_WRONGSEC on things we
shouldn't be, while still granting the spo_must_allow operation to succeed.
(based on [somthing-putfh-like]->...->[something-spo_must_allow-like]...->[end-or-putfh])

> To be honest, I've always been hazy on where in the spec the ramifications of
> SP4_MACH_CRED only covering part of a compound is discussed… I’ll take a
> look soon.

I think you mean 2.6.3.1? But it doesn't reference SP4_MACH_CRED
specifically, only 'acceptable security tuple'.

This may also be a little bit heavyweight for how the server is set up
currently. (i.e. simply changing the export (sec=krb5) to
(sec=krb5,krb5i) will eliminate the need for nfsd4_spo_must_allow()).

Thanks,

Andy

-- 
Andrew W. Elble
aweits@discipline.rit.edu
Infrastructure Engineer, Communications Technical Lead
Rochester Institute of Technology
PGP: BFAD 8461 4CCF DC95 DA2C B0EB 965B 082E 863E C912
