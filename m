Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:50577 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751947Ab1BOQUz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Feb 2011 11:20:55 -0500
Date: Tue, 15 Feb 2011 11:20:53 -0500
From: Jim Rees <rees@umich.edu>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Edgar Almonte <samudhio@gmail.com>, linux-nfs@vger.kernel.org
Subject: Re: NFS only mount with -o udp option
Message-ID: <20110215162053.GA7495@merit.edu>
References: <665D28F4-A8C9-47E8-AE27-E1D960A1830B@oracle.com>
 <AANLkTi=dgyOmf+to8waRi+piomovMM-H7_7GdzyhYuEo@mail.gmail.com>
 <0F40C51E-38A3-451B-9D88-586CFD82EF8F@oracle.com>
 <AANLkTiksVebz5Pc+hH55hRUgvQ5PMFE1DG2X1JWbtSeD@mail.gmail.com>
 <AANLkTinG0774DoYyM+2381Eyxdx0+29JUs_-dzfRp=vM@mail.gmail.com>
 <1A31AB06-8518-427C-8D0B-0058AA613D0E@oracle.com>
 <AANLkTimiACttSQ+=M0UNGs5nZrP=zs0zRFV+4HP8c-OP@mail.gmail.com>
 <81853901-909D-4803-81A5-C01C0337CAE1@oracle.com>
 <AANLkTim9zbEzKZ=RZbfZhcLovn6fWkdL-3eZp21-NDP+@mail.gmail.com>
 <2F1D1F4B-0623-4954-861C-2F7B37EB2CA7@oracle.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <2F1D1F4B-0623-4954-861C-2F7B37EB2CA7@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Chuck Lever wrote:

  On the server, look at the command line options for rpc.mountd.  I'm not
  familiar with Ubuntu or Debian's start-up scripts, so I can't be more
  specific than that.

This should be in /etc/default/nfs-kernel-server on Ubuntu.  Debian may be
the same.
