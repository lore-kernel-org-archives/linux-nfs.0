From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: [PATCH 03/19] sunrpc: make token header values less confusing
Date: Wed, 12 Mar 2008 12:44:25 -0400
Message-ID: <4d569c330803120944y2b72d4d2x66609dcc846511af@mail.gmail.com>
References: <20080221184208.19195.94518.stgit@jazz.citi.umich.edu>
	 <20080221184402.19195.57873.stgit@jazz.citi.umich.edu>
	 <20080312163104.GC10015@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, aglo@citi.umich.edu
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gv-out-0910.google.com ([216.239.58.188]:17934 "EHLO
	gv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751522AbYCLQo1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Mar 2008 12:44:27 -0400
Received: by gv-out-0910.google.com with SMTP id s4so686653gve.37
        for <linux-nfs@vger.kernel.org>; Wed, 12 Mar 2008 09:44:26 -0700 (PDT)
In-Reply-To: <20080312163104.GC10015@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 12, 2008 at 12:31 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Thu, Feb 21, 2008 at 01:44:02PM -0500, Kevin Coffman wrote:
>
>  Could you double-check this spkm3 case?  It looks like tokenlen is
>  passed to spkm3_make_mic_token as well as the two functions you've
>  modified.

Thanks, I will double-check (and actually test with!) spkm3 before
sending the next round.

K.C.
