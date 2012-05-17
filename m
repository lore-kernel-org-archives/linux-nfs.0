Return-Path: linux-nfs-owner@vger.kernel.org
Received: from DILBERT.FHCRC.ORG ([140.107.152.15]:35401 "EHLO
	dilbert.fhcrc.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933487Ab2EQXvf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 May 2012 19:51:35 -0400
Message-ID: <4FB58F06.3020106@fhcrc.org>
Date: Thu, 17 May 2012 16:51:34 -0700
From: Stuart Kendrick <skendric@fhcrc.org>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: ls stalls
References: <4FB43655.5040907@fhcrc.org> <4FB4397A.6060104@fhcrc.org> <C7DE94F7-9A05-43C1-81EF-10136AE3394E@oracle.com> <4FB4F932.8060104@fhcrc.org> <A364E35B-CDE6-44D7-8D99-06EDB31666D7@oracle.com>
In-Reply-To: <A364E35B-CDE6-44D7-8D99-06EDB31666D7@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> The file must reside in the directory you are listing, and it should be very large.  Typically dd'ing zeroes into a large file is a good way to starve non-writers.

Thanx Chuck.  I can replicate the problem, I've learned a lot about
dirty_bytes/dirty_ratio and I'm on my way to resolving this.

--sk
