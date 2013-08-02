Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44721 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751071Ab3HBS3E (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 2 Aug 2013 14:29:04 -0400
Date: Fri, 2 Aug 2013 14:29:00 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Adamson, Dros" <Weston.Adamson@netapp.com>
Cc: linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Re: SP4_MACH_CRED
Message-ID: <20130802182900.GN17581@fieldses.org>
References: <A0A1021A-64E6-4E0C-89A5-9F719C8E1AFC@netapp.com>
 <20130731213904.GB2668@fieldses.org>
 <75E5568D-320C-45A1-B7E6-23CE73217BAF@netapp.com>
 <20130731234800.GC2668@fieldses.org>
 <0E0FF4CB-4388-417B-9D1C-24940472D844@netapp.com>
 <20130802153215.GK17581@fieldses.org>
 <F833CAE7-7BD2-4946-89A9-DFB9674124E4@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <F833CAE7-7BD2-4946-89A9-DFB9674124E4@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 02, 2013 at 04:51:28PM +0000, Adamson, Dros wrote:
> On Aug 2, 2013, at 11:32 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> 
> > On Thu, Aug 01, 2013 at 02:03:29PM +0000, Adamson, Dros wrote:
> >> The other case we are aiming for with the client is to be able to use
> >> the machine cred in recovery when the user's creds expire so that
> >> flushing of buffers can happen once recovery is complete. Of course,
> >> if you don't want to see the flushing changes, this is useless.
> > 
> > Just so I understand: addressing this case would require allowing more
> > operations, right?  (OPEN to do the reclaim, for example.)
> 
> Correct.

That one seems bigger--I'm not sure how to keep it from becoming
"clients can write anywhere they want" without a lot of work (like, say,
storing on disk some information about which users have written from
that client recently).

--b.
