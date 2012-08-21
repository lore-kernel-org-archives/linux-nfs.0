Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.194]:54936 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751692Ab2HUS4y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Aug 2012 14:56:54 -0400
Date: Tue, 21 Aug 2012 14:42:30 -0400
From: Jim Rees <rees@umich.edu>
To: Sven Geggus <lists@fuchsschwanzdomain.de>, linux-nfs@vger.kernel.org
Subject: Re: NFS4: ssh + unlink(~/.Xauthority) delays
Message-ID: <20120821184230.GA13357@umich.edu>
References: <k0vgkt$mm0$1@ultimate100.geggus.net>
 <20120821125905.GA16550@umich.edu>
 <k10bib$1fi$1@ultimate100.geggus.net>
 <20120821170759.GA13076@umich.edu>
 <20120821180353.GB4561@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120821180353.GB4561@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Malahal Naineni wrote:

  NFS3 doesn't have delegations and this file placement should not be an
  issue in NFSv4 either if it is working correctly!

Xauthority doesn't belong in $HOME, it belongs on the local disk.  That has
nothing to do with NFS v3/v4.  It has to do with limiting distribution and
exposure of sensitive information.
