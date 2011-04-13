Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:49929 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752057Ab1DMSOe convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Apr 2011 14:14:34 -0400
Subject: Re: [RFC][PATCH] Vector read/write support for NFS (DIO) client
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Andy Adamson <andros@netapp.com>
Cc: Jeff Layton <jlayton@redhat.com>, Badari Pulavarty <pbadari@us.ibm.com>,
        Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
        khoa@us.ibm.com
In-Reply-To: <7497FEC4-F173-4E10-B571-B856471CB9FD@netapp.com>
References: <1302622335.3877.62.camel@badari-desktop>
	 <0DC51758-AE6C-4DD2-A959-8C8E701FEA4E@oracle.com>
	 <1302624935.3877.66.camel@badari-desktop>
	 <FF1EE11E-62EB-42B9-A4C9-7A2FE4C60D2F@oracle.com>
	 <1302630360.3877.72.camel@badari-desktop>
	 <20110413083656.12e54a91@tlielax.poochiereds.net>
	 <4DA5A899.3040202@us.ibm.com>
	 <20110413100228.680ace66@tlielax.poochiereds.net>
	 <1302704533.8571.12.camel@lade.trondhjem.org>
	 <20110413132034.459c68bb@corrin.poochiereds.net>
	 <7497FEC4-F173-4E10-B571-B856471CB9FD@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 13 Apr 2011 14:14:31 -0400
Message-ID: <1302718471.8571.48.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

