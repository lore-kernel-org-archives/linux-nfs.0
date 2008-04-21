From: "Janne Karhunen" <janne.karhunen@gmail.com>
Subject: Re: [patch] fix statd -n
Date: Mon, 21 Apr 2008 11:40:54 -0400
Message-ID: <24c1515f0804210840r101ce42ck9a5770aa0771d54b@mail.gmail.com>
References: <24c1515f0804170938s23fe3ea3pfe77355ed01d8bbf@mail.gmail.com>
	 <20080418173646.GC19038@fieldses.org> <480902CA.1070805@redhat.com>
	 <48090356.9020703@redhat.com> <20080418203225.GD28277@fieldses.org>
	 <24c1515f0804181346g5867fa1fqfbbcd13af25027cb@mail.gmail.com>
	 <20080421000214.GA5453@fieldses.org>
	 <24c1515f0804201749x47bee916y9970fe1102bfb5@mail.gmail.com>
	 <20080421021153.GC5453@fieldses.org>
	 <30C5E99C-CADB-469E-9862-857884A3B40B@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	"Peter Staubach" <staubach@redhat.com>, linux-nfs@vger.kernel.org
To: "Chuck Lever" <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.179]:38056 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753738AbYDUPky (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Apr 2008 11:40:54 -0400
Received: by wa-out-1112.google.com with SMTP id m16so3193645waf.23
        for <linux-nfs@vger.kernel.org>; Mon, 21 Apr 2008 08:40:54 -0700 (PDT)
In-Reply-To: <30C5E99C-CADB-469E-9862-857884A3B40B@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 21, 2008 at 11:01 AM, Chuck Lever <chuck.lever@oracle.com> wrote:

>  I think creating a separate loopback listener in the "-n" case is a
> reasonable thing to do, and probably won't be terribly complex.  This isn't
> a performance path, so you can probably get away with a select on multiple
> sockets.

I'm currently experimenting this by adding it a
statd_get_nlm_socket() and going through the
code to catch which socket should be used
and when..


-- 
// Janne
