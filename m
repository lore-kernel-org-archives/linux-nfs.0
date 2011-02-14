Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:47842 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751456Ab1BNXmJ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Feb 2011 18:42:09 -0500
Subject: Re: [PATCH 10/16] pnfs: wave 3: coelesce across layout stripes
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: andros@netapp.com
Cc: linux-nfs@vger.kernel.org, Fred Isaman <iisaman@netapp.com>,
        Andy Adamon <andros@citi.umich.edu>,
        Dean Hildebrand <dhildeb@us.ibm.com>,
        Fred Isaman <iisaman@citi.umich.edu>,
        Benny Halevy <bhalevy@panasas.com>,
        Boaz Harrosh <bharrosh@panasas.com>,
        Oleg Drokin <green@linuxhacker.ru>, Tao Guo <guotao@nrchpc.ac.cn>
In-Reply-To: <1297711116-3139-11-git-send-email-andros@netapp.com>
References: <1297711116-3139-1-git-send-email-andros@netapp.com>
	 <1297711116-3139-11-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 14 Feb 2011 18:42:00 -0500
Message-ID: <1297726920.23841.51.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2011-02-14 at 14:18 -0500, andros@netapp.com wrote: 
> From: Fred Isaman <iisaman@netapp.com>
> 
> Add a pg_test layout driver hook which is used to avoid coelescing I/O across
> layout stripes.

Doesn't this belong before [PATCH 09/16] pnfs: wave 3: shift
pnfs_update_layout locations?


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

