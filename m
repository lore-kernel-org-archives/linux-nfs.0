Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51937 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750918AbaJaUU1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 31 Oct 2014 16:20:27 -0400
Received: from bfields by fieldses.org with local (Exim 4.76)
	(envelope-from <bfields@fieldses.org>)
	id 1XkIgM-00005v-QF
	for linux-nfs@vger.kernel.org; Fri, 31 Oct 2014 16:20:26 -0400
Date: Fri, 31 Oct 2014 16:20:26 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: linux-nfs@vger.kernel.org
Subject: Re: wireshark
Message-ID: <20141031202026.GG17580@fieldses.org>
References: <20141027220848.GB32743@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20141027220848.GB32743@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 27, 2014 at 06:08:48PM -0400, bfields wrote:
> I've been getting frequent crashes with the latest wireshark.  I think
> it's fixed in:
> 
> 	git://linux-nfs.org/~bfields/wireshark.git master
> 
> I'll probably try to add seek and allocate support while I'm there, and
> pass it to wireshark upstream when I've got it better figured out.

Done, but not upstream yet.  Till then, something like:

	git clone git://linux-nfs.org/~bfields/wireshark.git
	cd wireshark
	./autogen.sh
	./configure
	make

should work.  (And you may discover you need to install some -devel
packages after the next-to-last step.)

--b.
