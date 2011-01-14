Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:45587 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757744Ab1ANPis (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 Jan 2011 10:38:48 -0500
Date: Fri, 14 Jan 2011 10:38:46 -0500
From: Jim Rees <rees@umich.edu>
To: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: 4.1 no-pnfs mount option?
Message-ID: <20110114153846.GA21766@merit.edu>
References: <20110114151945.GA21629@merit.edu>
 <AANLkTimSp6BTgk1YQonXd6HuVS-JEpQUWqsny7JymJsd@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <AANLkTimSp6BTgk1YQonXd6HuVS-JEpQUWqsny7JymJsd@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

William A. (Andy) Adamson wrote:

  No mount option - just configure your machine to not load any pnfs
  layoutdriver modules.

That works, thanks, but I was hoping for a way to have layout and non-layout
mounts going on at the same time.
