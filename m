Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:54315 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752874Ab1LZUSP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Dec 2011 15:18:15 -0500
Date: Mon, 26 Dec 2011 15:18:12 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: file locking fix for 3.2
Message-ID: <20111226201812.GB31492@fieldses.org>
References: <20111224215012.GA23495@fieldses.org>
 <20111224225525.GR23916@ZenIV.linux.org.uk>
 <20111224235035.GA23711@fieldses.org>
 <20111225000542.GS23916@ZenIV.linux.org.uk>
 <20111225181948.GA26288@fieldses.org>
 <alpine.LFD.2.02.1112261035240.27600@i5.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <alpine.LFD.2.02.1112261035240.27600@i5.linux-foundation.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 26, 2011 at 10:37:56AM -0800, Linus Torvalds wrote:
> 
> I'm committing the appended version instead. It removes all the games with 
> IS_ERR(), and just does the checking at the allocation point, the way the 
> other lease_alloc() user does too.
> 
> Holler if you see something odd in there..

Looks fine to me.

> @@ -1284,8 +1280,7 @@ restart:
>  
>  out:
>  	unlock_flocks();
> -	if (!IS_ERR(new_fl))
> -		locks_free_lock(new_fl);
> +	locks_free_lock(new_fl);
>  	return error;
>  }
>  

(And, oops, I missed that last check--thanks for catching it.)

--b.
