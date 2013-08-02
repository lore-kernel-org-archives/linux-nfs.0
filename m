Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57383 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753924Ab3HBPcQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 2 Aug 2013 11:32:16 -0400
Date: Fri, 2 Aug 2013 11:32:15 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Adamson, Dros" <Weston.Adamson@netapp.com>
Cc: linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Re: SP4_MACH_CRED
Message-ID: <20130802153215.GK17581@fieldses.org>
References: <A0A1021A-64E6-4E0C-89A5-9F719C8E1AFC@netapp.com>
 <20130731213904.GB2668@fieldses.org>
 <75E5568D-320C-45A1-B7E6-23CE73217BAF@netapp.com>
 <20130731234800.GC2668@fieldses.org>
 <0E0FF4CB-4388-417B-9D1C-24940472D844@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <0E0FF4CB-4388-417B-9D1C-24940472D844@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 01, 2013 at 02:03:29PM +0000, Adamson, Dros wrote:
> The other case we are aiming for with the client is to be able to use
> the machine cred in recovery when the user's creds expire so that
> flushing of buffers can happen once recovery is complete. Of course,
> if you don't want to see the flushing changes, this is useless.

Just so I understand: addressing this case would require allowing more
operations, right?  (OPEN to do the reclaim, for example.)

--b.
