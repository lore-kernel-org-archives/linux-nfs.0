From: Hadmut Danisch <hadmut@danisch.de>
Subject: Re: NFS incompatible with Solaris jumpstart
Date: Mon, 4 Oct 2004 10:11:30 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20041004081130.GA17971@danisch.de>
References: <Pine.HPX.4.58L.0410040041270.2874@punch.eng.cam.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S267777AbUJDIPT@vger.kernel.org>
To: "P. Benie" <pjb1008@eng.cam.ac.uk>
In-Reply-To: <Pine.HPX.4.58L.0410040041270.2874@punch.eng.cam.ac.uk>
List-ID: <nfs.lists.sourceforge.net>

On Mon, Oct 04, 2004 at 01:10:46AM +0100, P. Benie wrote:
> Re your jumpstart problem - a colleague in another department had trouble
> with this once. I don't think he had the time to fix the problem.
> 
> He did get as far as finding that the client got an error from the NFS
> server when accessing /dev/console. This would give the impression of
> hanging as soon as the kernel starts init. It should be easy to verify if
> you have the same problem using tcpdump.


/dev/ was a good hint. I found the problem:

When booting the Solaris system wants to write to the 
Boot environment (nasty, isn't it?).

Since the userspace daemon doesn't understand the /etc/exports syntax
of the kernel version, I wrote a different, simplified /etc/exports
for the userspace daemon. 

The userspace daemon allowed write access, the kernel version didn't. 
That was the problem.

regards
Hadmut
