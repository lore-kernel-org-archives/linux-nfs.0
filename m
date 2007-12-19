From: =?ISO-8859-2?Q?Tomasz_K=B3oczko?= <kloczek@rudy.mif.pg.gda.pl>
Subject: Re: [PATCH 0/7] Intro: convert lockd to kthread and fix use-after-free
 (try #3)
Date: Wed, 19 Dec 2007 20:15:43 +0100 (CET)
Message-ID: <Pine.BSO.4.63.0712192004140.3875@rudy.mif.pg.gda.pl>
References: <1198009182-27895-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="0-563880963-1198091743=:3875"
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755478AbXLSTQA@vger.kernel.org>
In-Reply-To: <1198009182-27895-1-git-send-email-jlayton@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--0-563880963-1198091743=:3875
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 8BIT

On Tue, 18 Dec 2007, Jeff Layton wrote:

> This is the third patchset to fix the use-after-free problem in lockd,
> and to convert lockd to use the kthread API instead of kernel_thread.
> The main change from the last patchset is the elimination of the
> svc_create_kthread helper function, and having lockd_up call kthread_run
> directly. I've also made some changes to the function prototype for
> the lockd function to eliminate the need for casting the function
> pointer.

BTW kernel, NFS and lockd: SuSE kernel IIRC is distributed with patch 
which adds kernel-based status monitor (statd).

Q to NFS people: any plans about merge this in main kernel tree ?

And another question related to NFS: any progress on add clear NFS 
statistics in kernel (nfsstat -z) ?

kloczek
-- 
-----------------------------------------------------------
*Ludzie nie maj± problemów, tylko sobie sami je stwarzaj±*
-----------------------------------------------------------
Tomasz K³oczko | *e-mail: kloczek@rudy.mif.pg.gda.pl*
--0-563880963-1198091743=:3875--
