From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [Bug 13034] printk in xs_tcp_setup_socket needs rate limit ...
 and delay
Date: Wed, 22 Apr 2009 20:52:57 -0400
Message-ID: <1240447977.9197.14.camel@heimdal.trondhjem.org>
References: <bug-13034-104@http.bugzilla.kernel.org/>
	 <200904222049.n3MKnxZi019947@demeter.kernel.org>
	 <1240433936.9197.9.camel@heimdal.trondhjem.org>
	 <49EF9896.2000301@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "bugzilla-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org"
	<bugzilla-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org>,
	Petr Vandrovec <petr@vandrovec.name>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jean Delvare <khali-PUYAD+kWke1g9hUCZPvPmw@public.gmane.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: Petr Vandrovec <petr@vmware.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:52465 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752256AbZDWAxj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Apr 2009 20:53:39 -0400
In-Reply-To: <49EF9896.2000301@vmware.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-04-22 at 15:22 -0700, Petr Vandrovec wrote:
> Trond Myklebust wrote:
> > So these connections are basically timing out because the systems are
> > idle? (FYI: the NFS convention is that clients are supposed to close the
> > TCP connection if it has been idle for 5 minutes, whereas the servers
> > usually close it if the client has been idle for 6 minutes)...
> 
> Yes, they are timing out because system is idle.  It seems that it 
> behaves way it should - it is client who closes them, 5 minutes after I 
> run 'df':

Good! The 5minute idle timeout is the one case where we don't care about
preserving the port number (because there are no outstanding NFS
requests to replay to the server).

Jean, are you seeing the same behaviour (i.e. errors only on idle
timeout), and is the fix working for you?


