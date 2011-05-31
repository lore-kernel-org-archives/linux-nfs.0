Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailout-de.gmx.net ([213.165.64.23]:55756 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750762Ab1EaJr1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 31 May 2011 05:47:27 -0400
From: =?utf-8?q?R=C3=BCdiger_Meier?= <sweet_f_a@gmx.de>
To: linux-nfs@vger.kernel.org
Subject: Re: infinite getdents64 loop
Date: Tue, 31 May 2011 11:47:24 +0200
References: <201105281502.32719.sweet_f_a@gmx.de> <201105301137.02061.sweet_f_a@gmx.de> <1306767521.5971.2.camel@lade.trondhjem.org>
In-Reply-To: <1306767521.5971.2.camel@lade.trondhjem.org>
Content-Type: text/plain;
  charset="utf-8"
Message-Id: <201105311147.24939.sweet_f_a@gmx.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Monday 30 May 2011, Trond Myklebust wrote:
> On Mon, 2011-05-30 at 11:37 +0200, Ruediger Meier wrote:
> >
> > Does this mean ext4 generally does not work with for nfs?
>
> ext2/3/4 are all known to have this problem when you switch on the
> hashed b-tree directories. Typically, a directory with a million
> entries will have several tens of cookie collisions.

Ok, like Jeff mentioned in the other reply disabling dir_index solves 
it.

I wish I had seen this documented somewhere before switching from xfs to 
ext4 but it's not easy to find something about these ext4/nfs probs 
without knowing the details already.
Ext4 being default file system on many distros made me feel safe.


thanks for helping,
Rudi 



