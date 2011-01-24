Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:53128 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752961Ab1AXXBP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Jan 2011 18:01:15 -0500
Date: Mon, 24 Jan 2011 18:01:11 -0500
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, Thomas Haynes <thomas@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: Re: Patched up cthon source?
Message-ID: <20110124230111.GB16444@merit.edu>
References: <E5AAF04F-8A0E-4506-A29D-A0CD4098AA64@netapp.com>
 <83EC814B-1043-46B2-8F5E-E1FB1F5B56BF@oracle.com>
 <4D3DFE40.1070605@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4D3DFE40.1070605@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Benny Halevy wrote:

  this is a problem with the version of nroff on newer distributions.
  The following patch fixed it for me last bakeathon:
  
  From f44b150809e43b129fad34e3e4ec288e4dd36e6c Mon Sep 17 00:00:00 2001

Maybe one of our Oracle friends (Chuck?) can push this upstream?  The
Connectathon web site still lists cthon04 as the official test suite.
