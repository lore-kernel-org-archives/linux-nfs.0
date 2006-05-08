From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfsstat for NFSv4
Date: Mon, 8 May 2006 18:25:31 -0400
Message-ID: <20060508222531.GA4849@fieldses.org>
References: <4452537B.AD69.00CC.0@novell.com> <445B8B54.AD69.00CC.0@novell.com>
	<445F9F92.AD69.00CC.0@novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: G.AllenMorrisIII@linux-nfs.org, nfsv4@linux-nfs.org, gam3@gam3.net,
	nfs@lists.sourceforge.net, Charles Lever <Charles.Lever@netapp.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
To: Shankar Anand <shanand@novell.com>
In-Reply-To: <445F9F92.AD69.00CC.0@novell.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <nfs.lists.sourceforge.net>

On Mon, May 08, 2006 at 08:14:19AM -0600, Shankar Anand wrote:
> I have added some code for NFSv4 server statistics for individual NFSv4
> operations. I will submitting that to the NFS community soon.
> 
> I have some questions:
> 1. I noticed in Allen's patch for nfsstat for NFSv4 statistics that he
> has taken into account only 32 NFSv4 operations. Do you have any reasons
> for leaving out the other operations (like PUTFH, SECINFO, SAVEFH)? 

At a guess: PUTFH and SAVEFH aren't particularly interesting, and
SECINFO isn't implemented yet on the server (and isn't used yet on the
client).

--b.
