From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [patch 03/29] knfsd: add userspace controls for stats tables
Date: Tue, 28 Apr 2009 12:26:02 -0400
Message-ID: <20090428162602.GJ17891@fieldses.org>
References: <20090331202800.739621000@sgi.com> <20090331202938.939647000@sgi.com> <20090425215745.GA5088@fieldses.org> <20090425220329.GB5088@fieldses.org> <A11EACD6-B05E-4A1A-A38C-F65B2DFB77B3@oracle.com> <20090427232225.GB5108@fieldses.org> <4993A7C8-342E-47BE-997A-AF18E5DF41BE@oracle.com> <20090428155736.GH17891@fieldses.org> <223A8BE7-4083-4222-83B8-6BB6C4107016@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Banks <gnb-xTcybq6BZ68@public.gmane.org>, Linux NFS ML <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:46161 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756690AbZD1Q0F (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Apr 2009 12:26:05 -0400
In-Reply-To: <223A8BE7-4083-4222-83B8-6BB6C4107016@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 28, 2009 at 12:03:49PM -0400, Chuck Lever wrote:
> I'm OK with more brevity in these comments as long as we recognize that 
> the devil is in the details.  We should preserve the specificity of the 
> API descriptions.
>
> I think it was you who was complaining recently about knowing whether a 
> \n or a \0 is expected at the end of some of these strings.  ;-)

Oh, absolutely, I do appreciate the fact that we've got some
documentation there.

--b.
