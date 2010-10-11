Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:33825 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750842Ab0JKAUY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 10 Oct 2010 20:20:24 -0400
Date: Sun, 10 Oct 2010 20:20:22 -0400
From: Jim Rees <rees@umich.edu>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 02/15] libnfs.a: Allow multiple RPC listeners to share
 listener port number
Message-ID: <20101011002022.GB25663@merit.edu>
References: <20101010234836.6667.4057.stgit@ellison.1015granger.net>
 <20101011000421.6667.60700.stgit@ellison.1015granger.net>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20101011000421.6667.60700.stgit@ellison.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Chuck Lever wrote:

  Normally, when "-p" is not specified on the mountd command line, the
  TI-RPC library chooses random port numbers for each listener.  If a
  port number _is_ specified on the command line, all the listeners
  will get the same port number, so SO_REUSEADDR needs to be set on
  each socket.
  
  Thus we can't let TI-RPC create the listener sockets for us in this
  case; we must create them ourselves and then set SO_REUSEADDR (and
  other socket options) by hand.

It bothers me that there are two separate code paths in two separate
libraries for these two nearly identical cases.  Wouldn't it be better to
add this functionality to tirpc?
