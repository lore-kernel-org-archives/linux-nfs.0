Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:39320 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757208Ab0JEWvM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Oct 2010 18:51:12 -0400
Date: Tue, 5 Oct 2010 18:50:45 -0400
From: Jim Rees <rees@umich.edu>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Steve Dickson <steved@redhat.com>, NFS list <linux-nfs@vger.kernel.org>
Subject: Re: use squid proxy for yum access in the lab
Message-ID: <20101005225045.GB16399@merit.edu>
References: <4CABA094.50100@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4CABA094.50100@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Boaz Harrosh wrote:

  install squid on laptop:
  []$ yum install squid
  
  start it:
  []$ service squid start
  
  Then at each lab machine:
  export http_proxy=http://192.168.12.228:3128

I also had to comment out the mirrorlist in the repo files, then pick a
mirror and put it in as baseurl.  I guess because the mirrorlist is https?
