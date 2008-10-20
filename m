From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Get rid of empty AUTHORS file
Date: Mon, 20 Oct 2008 14:53:46 -0400
Message-ID: <20081020185346.GC25796@fieldses.org>
References: <alpine.LNX.1.10.0810182047070.17929@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Jan Engelhardt <jengelh-nopoi9nDyk+ELgA04lAiVw@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:46750 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751752AbYJTSxs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Oct 2008 14:53:48 -0400
In-Reply-To: <alpine.LNX.1.10.0810182047070.17929-vVwEwcwQeYFPkBl3ERsXe1l1cybopEuJUBSOeVevoDU@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Oct 18, 2008 at 08:48:11PM -0400, Jan Engelhardt wrote:
> the AUTHORS file reads:
> 
> 	This is a dummy AUTHORS file to make automake happy.
> 
> You can make automake happy in an IMO better way:
> 
> 	AUTOMAKE_OPTIONS = foreign
> 
> at the top of the toplevel Makefile.am.
> (I usually also prefer "AUTOMAKE_OPTIONS = subdir-objs" next to 
> foreign.)

The quickest way to get changes into nfs-utils these days is a patch
sent to steved@redhat.com against git://linux-nfs.org/nfs-utils.

--b.
