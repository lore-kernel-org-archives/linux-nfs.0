Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:26385 "EHLO
	us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751523AbcEYST0 convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 May 2016 14:19:26 -0400
From: Thomas Haynes <loghyr@primarydata.com>
To: hch <hch@lst.de>
CC: Thomas Haynes <loghyr@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 4/4] nfsd: Provide a config option for flex file layouts
Date: Wed, 25 May 2016 18:19:20 +0000
Message-ID: <5F7AEB38-6AFE-4BB5-B52A-3EF358FF5B46@primarydata.com>
References: <1464152979-103988-1-git-send-email-loghyr@primarydata.com>
 <1464152979-103988-5-git-send-email-loghyr@primarydata.com>
 <20160525150917.GC27535@lst.de>
In-Reply-To: <20160525150917.GC27535@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On May 25, 2016, at 8:09 AM, Christoph Hellwig <hch@lst.de> wrote:
> 
>> +config NFSD_FLEXFILELAYOUT
>> +	bool "NFSv4.1 server support for pNFS Flex File layouts"
>> +	depends on NFSD_V4
>> +	select NFSD_PNFS
>> +	help
>> +	  This option enables support for the exporting pNFS Flex File
>> +	  layouts in the kernel's NFS server. The pNFS Flex File  layout
>> +	  enables NFS clients to directly perform I/O to NFSv3 devices
>> +	  accesible to both the server and the clients.  See
>> +	  draft-ietf-nfsv4-flex-files for more details.
> 
> How about a bit more of a warning that this is just a toy demo server?
> 

Add:

          Warning, this server implements the bare minimum functionality for
          to be a flex file server - it is more for testing the client
          than for a production server.




> Also I'd say merge this into the previous patch.
> 

Agreed

