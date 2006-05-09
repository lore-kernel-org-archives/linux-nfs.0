From: "Shankar Anand" <shanand@novell.com>
Subject: Re: nfsstat for NFSv4
Date: Tue, 09 May 2006 07:52:55 -0600
Message-ID: <4460EC0F.AD69.00CC.0@novell.com>
References: <4452537B.AD69.00CC.0@novell.com> <445B8B54.AD69.00CC.0@novell.com>
	<445F9F92.AD69.00CC.0@novell.com>
	<20060508222531.GA4849@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: , gam3@gam3.net, G.AllenMorrisIII@linux-nfs.org,
	Charles Lever <Charles.Lever@netapp.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
To: "J. Bruce Fields" <bfields@fieldses.org>,<nfsv4@linux-nfs.org>,
	<nfs@lists.sourceforge.net>
In-Reply-To: <20060508222531.GA4849@fieldses.org>
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

Hi,

> "J. Bruce Fields" <bfields@fieldses.org> 5/9/2006 3:55:31 am >>>
>>On Mon, May 08, 2006 at 08:14:19AM -0600, Shankar Anand wrote:
>> I have added some code for NFSv4 server statistics for individual
NFSv4
>> operations. I will submitting that to the NFS community soon.
> 
>> I have some questions:
>> 1. I noticed in Allen's patch for nfsstat for NFSv4 statistics that
he
>> has taken into account only 32 NFSv4 operations. Do you have any
reasons
>> for leaving out the other operations (like PUTFH, SECINFO, SAVEFH)?


> At a guess: PUTFH and SAVEFH aren't particularly interesting, and
> SECINFO isn't implemented yet on the server (and isn't used yet on
the
> client).

But the problem with this is that we skip operations in between,  
which breaks the order of the operations given in the RFC i.e. the
linear order
in which the statistics are captured in the NFSv4 server.
Just want to know why this was done when capturing the count for an
extra
procedure does not require much extra effort, going by the existing
code and 
actually causes a break in the list of operation numbers.

>> 2. I understand that in NFSv3 server we write the statistics into
>> /proc/net/rpc/nfsd in the same order as the RPC procedure numbers.
Using
>> the same logic, I have written the NFSv4 statistics to be logged
into
>> /proc/net/rpc/nfsd in the same order in which the operations are
listed
>> in the NFSv4 RFC. But the NFSv4 client statistics that are getting
>> printed in Allen's patch seem to be of a different order. Why was
this
>> decided to be so?

It would be great if someone can answer this too.

Regards,
Shankar
