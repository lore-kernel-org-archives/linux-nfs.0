From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [Bug 13034] printk in xs_tcp_setup_socket needs rate limit ...
 and delay
Date: Wed, 22 Apr 2009 16:58:56 -0400
Message-ID: <1240433936.9197.9.camel@heimdal.trondhjem.org>
References: <bug-13034-104@http.bugzilla.kernel.org/>
	 <200904222049.n3MKnxZi019947@demeter.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Petr Vandrovec <petr@vandrovec.name>,
	Andrew Morton <akpm@linux-foundation.org>, khali-PUYAD+kWke1g9hUCZPvPmw@public.gmane.org,
	linux-nfs@vger.kernel.org
To: bugzilla-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:53784 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752967AbZDVU7F (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Apr 2009 16:59:05 -0400
In-Reply-To: <200904222049.n3MKnxZi019947-jEpIWWs/U2wOASNP4CLbKB2eb7JE58TQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

(Switching to bugzilla email interface, and ccing linux-nfs)

On Wed, 2009-04-22 at 20:49 +0000, bugzilla-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org
wrote:
> http://bugzilla.kernel.org/show_bug.cgi?id=13034
> 
> 
> 
> 
> 
> --- Comment #12 from Petr Vandrovec <petr@vandrovec.name>  2009-04-22 20:49:58 ---
> Unfortunately I have no access to the server (they are some NetApp and EMC
> storage devices maintained by company IT).
> 
> It seems that they are all configured same way, so after mount they start
> timing out connections all at the same moment (after 10 minutes since mount, or
> something like that), and netstat above is captured when I run 'df' after
> connections moved from established to time_wait on client side.  That TIME_WAIT
> disappear after 60 seconds, as expected.

So these connections are basically timing out because the systems are
idle? (FYI: the NFS convention is that clients are supposed to close the
TCP connection if it has been idle for 5 minutes, whereas the servers
usually close it if the client has been idle for 6 minutes)...


