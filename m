Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-iy0-f174.google.com ([209.85.210.174]:46900 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754114Ab2DJAAS convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Apr 2012 20:00:18 -0400
Received: by iagz16 with SMTP id z16so6554579iag.19
        for <linux-nfs@vger.kernel.org>; Mon, 09 Apr 2012 17:00:18 -0700 (PDT)
References: <1334013727-1931-1-git-send-email-rees@umich.edu> <787F4D40-6513-4424-A297-FD608268EA56@oracle.com>
In-Reply-To: <787F4D40-6513-4424-A297-FD608268EA56@oracle.com>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain;
	charset=us-ascii
Message-Id: <BCB4197C-4B6A-4935-846C-681126BD7E30@gmail.com>
Cc: Jim Rees <rees@umich.edu>, Trond Myklebust <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
From: Fred Isaman <faisaman4@gmail.com>
Subject: Re: [PATCH] fix page number calculation bug for block layout decode buffer
Date: Mon, 9 Apr 2012 20:00:12 -0400
To: Chuck Lever <chuck.lever@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>





On Apr 9, 2012, at 7:25 PM, Chuck Lever <chuck.lever@oracle.com> wrote:

> Hi-
> 
> Since all the layouts (and I'm guessing the non-pNFS path too) seem to need this calculation, would it make sense to create an inline function in a header somewhere?
> 

nfs_page_array_len(0, size) would work. 

Fred