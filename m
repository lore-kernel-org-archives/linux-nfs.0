From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.32.2 - WARNING: at lib/kref.c:43 kref_get+0x,23/0x2b()
Date: Fri, 22 Jan 2010 15:03:25 -0800
Message-ID: <20100122150325.6ad12428.akpm@linux-foundation.org>
References: <4B4F5A00.4060604@atmos.washington.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Harry Edmon <harry-qmPYOCrcNLLyFCzt5hm0YvZ8FUJU4vz8@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:52614 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754502Ab0AVXDj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Jan 2010 18:03:39 -0500
In-Reply-To: <4B4F5A00.4060604-qmPYOCrcNLLyFCzt5hm0YvZ8FUJU4vz8@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

(cc linux-nfs)

On Thu, 14 Jan 2010 09:53:04 -0800
Harry Edmon <harry-qmPYOCrcNLLyFCzt5hm0YvZ8FUJU4vz8@public.gmane.org> wrote:

> I have a single quad-core Xeon machine running 2.6.32.2 that keeps 
> giving me "WARNING: at lib/kref.c:43 kref_get+0x,23/0x2b()".  This 
> machine is mainaly used as a NFS server.  I have attached the kern.log 
> and my config file.   Any ideas?
> -- 
> 
>  Dr. Harry Edmon			E-MAIL: harry-qmPYOCrcNLLyFCzt5hm0YvZ8FUJU4vz8@public.gmane.org
>  206-543-0547 FAX: 206-543-0308		harry-B93hV6UPU7Z2icitjWtXSw@public.gmane.org, harry@uw.edu
>  Director of IT, College of the Environment and
>  Director of Computing, Dept of Atmospheric Sciences
>  University of Washington, Box 351640, Seattle, WA 98195-1640
> 
> 
