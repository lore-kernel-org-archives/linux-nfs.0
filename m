Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:37832 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751336AbbHSAdw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Aug 2015 20:33:52 -0400
Received: by wibhh20 with SMTP id hh20so122422525wib.0
        for <linux-nfs@vger.kernel.org>; Tue, 18 Aug 2015 17:33:51 -0700 (PDT)
Subject: Re: [BUG] nfs-utils broken with musl
To: Chuck Lever <chuck.lever@oracle.com>
References: <55D3AA7E.2050606@gmail.com>
 <F1351211-433D-4386-889B-BA023442CC13@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Tastky <tastky@gmail.com>
Message-ID: <55D3CEEE.4050303@gmail.com>
Date: Wed, 19 Aug 2015 02:33:50 +0200
MIME-Version: 1.0
In-Reply-To: <F1351211-433D-4386-889B-BA023442CC13@oracle.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

OpenWrt does not use libtirpc and disables it via the utils compile 
configuration.

I'm really not sure about a lot regarding this issue though.

Anyway, I'd suggest keeping this discussion limited on the musl list, 
it'll quickly get confusing otherwise.

On 19.08.2015 01:59, Chuck Lever wrote:
 > Are you sure this isn't a libtirpc issue?> > > --> Chuck Lever
