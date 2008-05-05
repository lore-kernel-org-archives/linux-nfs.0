From: "Janne Karhunen" <janne.karhunen@gmail.com>
Subject: Re: [patch] fix statd -n
Date: Mon, 5 May 2008 13:10:23 -0400
Message-ID: <24c1515f0805051010l45667358v98ee9a3ee46f160b@mail.gmail.com>
References: <24c1515f0805021724q7dfe5294r702a9c8ffde01129@mail.gmail.com>
	 <481F20B6.8080603@gmail.com>
	 <24c1515f0805050801m66cce68k94073914ba26511e@mail.gmail.com>
	 <481F2600.20501@gmail.com>
	 <24c1515f0805050823s14f4caf7s3a4ff06a70c220be@mail.gmail.com>
	 <20080505152519.GE8259@fieldses.org>
	 <24c1515f0805050828o3aa5b33aod2a6e4e0b5b6c9dc@mail.gmail.com>
	 <20080505155858.GF8259@fieldses.org>
	 <24c1515f0805050942h26a0aaefi471216482fbabef5@mail.gmail.com>
	 <20080505170228.GB11809@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Wendy Cheng" <s.wendy.cheng@gmail.com>,
	"Peter Staubach" <staubach@redhat.com>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.182]:17140 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751437AbYEERKY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 May 2008 13:10:24 -0400
Received: by wa-out-1112.google.com with SMTP id j37so802943waf.23
        for <linux-nfs@vger.kernel.org>; Mon, 05 May 2008 10:10:23 -0700 (PDT)
In-Reply-To: <20080505170228.GB11809@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 5, 2008 at 1:02 PM, J. Bruce Fields <bfields@fieldses.org> wrote:

>  > So the only thing missing would be to limit the port visibility
>  > of long-standing sockets; but this should probably be
>  > discussed in another thread if you think it's worth it?
>
>  Is the only justification just to limit the consequences if a remote
>  exploit is found in statd?

It will also make it a LOT easier to debug and understand.
Discussions like this would have never existed given that
binds would have been specific.


-- 
// Janne
