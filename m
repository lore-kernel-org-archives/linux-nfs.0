Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:41532 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751072Ab1CKRDi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Mar 2011 12:03:38 -0500
Date: Fri, 11 Mar 2011 12:03:35 -0500
From: Jim Rees <rees@umich.edu>
To: =?utf-8?B?55m95p2+5p6X?= <09120171@bjtu.edu.cn>
Cc: linux-nfs@vger.kernel.org
Subject: Re: questions about blocklayoutdriver
Message-ID: <20110311170335.GB3096@merit.edu>
References: <RYMHGFHUOWTREOPCEMWIBKKRWODC.09120171@bjtu.edu.cn>
Content-Type: text/plain; charset=utf-8
In-Reply-To: <RYMHGFHUOWTREOPCEMWIBKKRWODC.09120171@bjtu.edu.cn>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

白松林 wrote:

  In the
  webpage(http://wiki.linuxnfs.org/wiki/index.php/PNFS_Block_Server_Setup_Instructions),
  there is one sentence, mount -t nfs4 -o minorversion=1 SN:/ /mnt/ob In
  this sentence,whether the SN means a MDS or means a DS?

MDS.
