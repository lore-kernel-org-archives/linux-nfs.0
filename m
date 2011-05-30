From: Ruediger Meier <sweet_f_a@gmx.de>
Subject: Re: infinite getdents64 loop
Date: Mon, 30 May 2011 11:37:01 +0200
Message-ID: <201105301137.02061.sweet_f_a@gmx.de>
References: <201105281502.32719.sweet_f_a@gmx.de> <201105291855.04487.sweet_f_a@gmx.de> <1306688643.2386.24.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailout-de.gmx.net ([213.165.64.22]:40001 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751687Ab1E3JhF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 May 2011 05:37:05 -0400
In-Reply-To: <1306688643.2386.24.camel-SyLVLa/KEI9HwK5hSS5vWB2eb7JE58TQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sunday 29 May 2011, Trond Myklebust wrote:
> It's actually a problem with the underlying filesystem: it is
> generating readdir 'offsets' that are not unique. In other words, if

Does this mean ext4 generally does not work with for nfs?


cu,
Rudi
