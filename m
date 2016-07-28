Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:35615 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758735AbcG1Oqm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Jul 2016 10:46:42 -0400
Date: Thu, 28 Jul 2016 07:46:41 -0700
From: Christoph Hellwig <hch@infradead.org>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Subject: Re: xfstests generic/285 fails reliably on Trond's linux-next branch
Message-ID: <20160728144641.GA28753@infradead.org>
References: <20160721081802.GA14413@infradead.org>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="J/dobhs11T7y2rNN"
In-Reply-To: <20160721081802.GA14413@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--J/dobhs11T7y2rNN
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Jul 21, 2016 at 01:18:02AM -0700, Christoph Hellwig wrote:
> Now that 207 is fixed the next test starts failing..  285 is
> the SEEK_HOLE/DATA sanity check, which might help with figuring out
> which of the recent changes introduced it.

A week later this still fails with the linux-next branch. Plain NFSv4.2
against a Linux/XFS server.  The 285.full file documenting the failures
is attached below:

--J/dobhs11T7y2rNN
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="285.full"

File system magic#: 0x6969
Allocation size: 524288

01. Test empty file                                   
01.01 SEEK_DATA expected -1 with errno -6, got -6.                succ
01.02 SEEK_HOLE expected -1 with errno -6, got -6.                succ
01.03 SEEK_HOLE expected -1 with errno -6, got -6.                succ

02. Test a tiny full file                             
02.01 SEEK_HOLE expected 8 or 8, got 8.                           succ
02.02 SEEK_DATA expected 0 or 0, got 0.                           succ
02.03 SEEK_DATA expected 1 or 1, got 1.                           succ
02.04 SEEK_HOLE expected 8 or 8, got 8.                           succ
02.05 SEEK_DATA expected 7 or 7, got 7.                           succ
02.06 SEEK_HOLE expected -1 with errno -6, got -6.                succ
02.07 SEEK_DATA expected -1 with errno -6, got -6.                succ
02.08 SEEK_HOLE expected -1 with errno -6, got -6.                succ
02.09 SEEK_DATA expected -1 with errno -6, got -6.                succ

03. Test a larger full file                           
03.01 SEEK_HOLE expected 1048676 or 1048676, got 1048676.         succ
03.02 SEEK_HOLE expected 1048676 or 1048676, got 1048676.         succ
03.03 SEEK_DATA expected 0 or 0, got 0.                           succ
03.04 SEEK_DATA expected 1 or 1, got 1.                           succ
03.05 SEEK_HOLE expected 1048676 or 1048676, got 1048676.         succ
03.06 SEEK_DATA expected 1048675 or 1048675, got 1048675.         succ
03.07 SEEK_HOLE expected -1 with errno -6, got -6.                succ
03.08 SEEK_DATA expected -1 with errno -6, got -6.                succ
03.09 SEEK_HOLE expected -1 with errno -6, got -6.                succ
03.10 SEEK_DATA expected -1 with errno -6, got -6.                succ

04. Test file hole at beg, data at end                
04.01 SEEK_HOLE expected 0 or 1048584, got 0.                     succ
04.02 SEEK_HOLE expected 1 or 1048584, got 1.                     succ
04.03 SEEK_DATA expected 1048576 or 1048576, got 1048576.         succ
04.04 SEEK_DATA expected 1048576 or 1048576, got 1048576.         succ
04.05 SEEK_HOLE expected 1048575 or 1048584, got 1048575.         succ
04.06 SEEK_DATA expected 1048576 or 1048576, got 1048576.         succ
04.07 SEEK_HOLE expected 1048584 or 1048584, got 1048584.         succ
04.08 SEEK_DATA expected 1048576 or 1048576, got 1048576.         succ
04.09 SEEK_HOLE expected 1048584 or 1048584, got 1048584.         succ
04.10 SEEK_DATA expected 1048577 or 1048577, got 1048577.         succ
04.11 SEEK_HOLE expected 1048584 or 1048584, got 1048584.         succ
04.12 SEEK_DATA expected 1048583 or 1048583, got 1048583.         succ
04.13 SEEK_HOLE expected -1 with errno -6, got -6.                succ
04.14 SEEK_DATA expected -1 with errno -6, got -6.                succ
04.15 SEEK_HOLE expected -1 with errno -6, got -6.                succ
04.16 SEEK_DATA expected -1 with errno -6, got -6.                succ

05. Test file data at beg, hole at end                
05.01 SEEK_HOLE expected 524288 or 2097152, got 524288.           succ
05.02 SEEK_HOLE expected 524288 or 2097152, got 524288.           succ
05.03 SEEK_DATA expected 0 or 0, got 0.                           succ
05.04 SEEK_DATA expected 1 or 1, got 1.                           succ
05.05 SEEK_HOLE expected 524288 or 2097152, got 524288.           succ
05.06 SEEK_DATA expected 524287 or 524287, got 524287.            succ
05.07 SEEK_HOLE expected 524288 or 2097152, got 524288.           succ
05.08 SEEK_DATA expected -1 with errno -6, got -6.                succ
05.09 SEEK_HOLE expected 524289 or 2097152, got 524289.           succ
05.10 SEEK_DATA expected -1 with errno -6, got -6.                succ
05.11 SEEK_HOLE expected 2097151 or 2097152, got 2097151.         succ
05.12 SEEK_DATA expected -1 with errno -6, got -6.                succ
05.13 SEEK_HOLE expected -1 with errno -6, got -6.                succ
05.14 SEEK_DATA expected -1 with errno -6, got -6.                succ
05.15 SEEK_HOLE expected -1 with errno -6, got -6.                succ
05.16 SEEK_DATA expected -1 with errno -6, got -6.                succ

06. Test file hole data hole data                     
06.01 SEEK_HOLE expected 0 or 2097152, got 0.                     succ
06.02 SEEK_HOLE expected 1 or 2097152, got 1.                     succ
06.03 SEEK_DATA expected 524288 or 524288, got 524288.            succ
06.04 SEEK_DATA expected 524288 or 524288, got 524288.            succ
06.05 SEEK_HOLE expected 524287 or 2097152, got 524287.           succ
06.06 SEEK_DATA expected 524288 or 524288, got 524288.            succ
06.07 SEEK_HOLE expected 1048576 or 2097152, got 1507328.         FAIL
06.08 SEEK_DATA expected 524288 or 524288, got 524288.            succ
06.09 SEEK_HOLE expected 1048576 or 2097152, got 1507328.         FAIL
06.10 SEEK_DATA expected 524289 or 524289, got 524289.            succ
06.11 SEEK_HOLE expected 1048576 or 2097152, got 1507328.         FAIL
06.12 SEEK_DATA expected 1048575 or 1048575, got 1048575.         succ
06.13 SEEK_HOLE expected 1048576 or 2097152, got 1507328.         FAIL
06.14 SEEK_DATA expected 1572864 or 1572864, got 1048576.         FAIL
06.15 SEEK_HOLE expected 1048577 or 2097152, got 1507328.         FAIL
06.16 SEEK_DATA expected 1572864 or 1572864, got 1048577.         FAIL
06.17 SEEK_HOLE expected 1572863 or 2097152, got 1572863.         succ
06.18 SEEK_DATA expected 1572864 or 1572864, got 1572864.         succ
06.19 SEEK_HOLE expected 2097152 or 2097152, got 2097152.         succ
06.20 SEEK_DATA expected 1572864 or 1572864, got 1572864.         succ
06.21 SEEK_HOLE expected 2097152 or 2097152, got 2097152.         succ
06.22 SEEK_DATA expected 1572865 or 1572865, got 1572865.         succ
06.23 SEEK_HOLE expected 2097152 or 2097152, got 2097152.         succ
06.24 SEEK_DATA expected 2097151 or 2097151, got 2097151.         succ
06.25 SEEK_HOLE expected -1 with errno -6, got -6.                succ
06.26 SEEK_DATA expected -1 with errno -6, got -6.                succ
06.27 SEEK_HOLE expected -1 with errno -6, got -6.                succ
06.28 SEEK_DATA expected -1 with errno -6, got -6.                succ

seek sanity check failed!

--J/dobhs11T7y2rNN--
