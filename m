Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f173.google.com ([209.85.223.173]:54541 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751515Ab3LBN3E convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Dec 2013 08:29:04 -0500
Received: by mail-ie0-f173.google.com with SMTP id to1so20181624ieb.4
        for <linux-nfs@vger.kernel.org>; Mon, 02 Dec 2013 05:29:03 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.0 \(1812\))
Subject: Re: Linux client access to NFSv4 Alternate Data Streams (O_XATTR)?
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <CAEEMktPamgjSHA_OmHj73ti5G01DcC_ykYb=-_bfOYqy4nW8BA@mail.gmail.com>
Date: Mon, 2 Dec 2013 08:29:01 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <5B7CDA5C-C3F1-4CFD-9A72-013523068FBB@primarydata.com>
References: <CAEEMktPamgjSHA_OmHj73ti5G01DcC_ykYb=-_bfOYqy4nW8BA@mail.gmail.com>
To: Joshuah Hurst <joshhurst@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Dec 2, 2013, at 7:13, Joshuah Hurst <joshhurst@gmail.com> wrote:

> We need to access NFSv4 Alternate Data Streams (what Solaris,
> NexentaOS, Omnios and SmartOS can openat() with the O_XATTR flag) from
> a (Suse) Linux client.
> 
> OS is Suse Linux 12.3, x86-64, 64bit
> 
> Does anyone know how to archive this?

Why can’t you access Solaris-specific extensions from a Solaris client?

Trond