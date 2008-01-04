From: Tom Haynes <tdh@excfb.com>
Subject: Re: A new NFSv4 server...
Date: Fri, 04 Jan 2008 12:03:54 -0600
Message-ID: <477E750A.2030905@excfb.com>
References: <200801041528.KAA18776@snowhite.cis.uoguelph.ca>
	<20080104172142.GD17112@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20080104172142.GD17112@fieldses.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> Ditto.  I think it'd be great to have a variety of client and server
> implementations available over the net, but I've had no luck talking
> anybody else into it.
>
> --b.
> _______________________________________________
> NFSv4 mailing list
> NFSv4@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
>   


I suspect that the explosion of virtual servers has
probably killed this type of effort. It appears much
easier for me to give you an image than to expose
a machine on the network.

Sun actually has a set of test machines the public can
use to regression test OpenSolaris fixes. I'm not sure
if it can accommodate foreign OSes just yet.

And to add to Rick's story, we've got the pNFS enabled
bits available for download. We've only gotten feedback
from one person. So either our code is really great and
we are not getting feedback, or people are just waiting
for the pNFS implementations to mature.

We did get a request to make the bits available as a
VMware image. :->
