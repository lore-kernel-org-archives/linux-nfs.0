Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.194]:55392 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750928AbaAONh1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Jan 2014 08:37:27 -0500
Date: Wed, 15 Jan 2014 08:37:22 -0500
From: Jim Rees <rees@umich.edu>
To: Stuart Kendrick <stuart.kendrick.sea@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: unable to send TCP SYNs from ports lower than 1024
Message-ID: <20140115133722.GA12243@umich.edu>
References: <CAACXELkPL0g8SNrYWSGoh+-0Uo4pbHeWGa5rtv_7X6vviAnkMQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAACXELkPL0g8SNrYWSGoh+-0Uo4pbHeWGa5rtv_7X6vviAnkMQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Stuart Kendrick wrote:

  Is anyone else seeing this?  This issue prevents NFS client mounting,
  since the NFS client wants to use source ports below 1024

It seems pretty unlikely this is actually broken without anyone noticing.
Did you check your iptables and switch acls?
