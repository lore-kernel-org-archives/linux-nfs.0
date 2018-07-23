Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:47928 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2388022AbeGWVgA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 23 Jul 2018 17:36:00 -0400
Date: Mon, 23 Jul 2018 16:33:06 -0400
From: Bruce Fields <bfields@fieldses.org>
To: Marc Eshel <eshel@us.ibm.com>
Cc: Libtirpc-devel Mailing List
        <libtirpc-devel@lists.sourceforge.net>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        linux-nfs-owner@vger.kernel.org
Subject: Re: your mail
Message-ID: <20180723203306.GA27515@fieldses.org>
References: <20180711152521.8238-1-steved@redhat.com>
 <OFA232E502.EADD3A82-ON882582D3.00667F9D-882582D3.0066E0F8@notes.na.collabserv.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <OFA232E502.EADD3A82-ON882582D3.00667F9D-882582D3.0066E0F8@notes.na.collabserv.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 23, 2018 at 11:43:55AM -0700, Marc Eshel wrote:
> Do you know of any plans to add  IETF RFC 8276 - File System Extended 
> Attributes in NFSv4 to the Linux NFS Client or Server?

I don't understand why you proposed new protocol without having anyone
in mind to implement it on the platforms where you need it.

Matt Benjamin's expressed interest in the past, but he's got a lot on
his plate so I don't know that we can count on that.

--b.
