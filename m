From: "Shankar Anand" <shanand@novell.com>
Subject: Re: PATCH [1/2] Capture nfsv4 server operations statistics
Date: Tue, 30 May 2006 08:30:25 -0600
Message-ID: <447CA45A.AD69.00CC.0@novell.com>
References: <4469C82B.AD69.00CC.0@novell.com>
	<20060517213638.GE11237@fieldses.org> <446E3040.AD69.00CC.0@novell.com>
	<20060519162747.GI3721@fieldses.org> <446F1B9F.AD69.00CC.0@novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <nfsv4-bounces@linux-nfs.org>
To: <bfields@fieldses.org>,<nfsv4@linux-nfs.org>, <nfs@lists.sourceforge.net>
In-Reply-To: <446F1B9F.AD69.00CC.0@novell.com>
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

> On 5/20/2006 at 1:37:34 pm,  "Shankar Anand" <shanand@novell.com>
wrote:
> Hi,
> 
>> On 5/19/2006 at 9:57:47 pm,
>> "J. Bruce Fields" <bfields@fieldses.org> wrote:
>> On Fri, May 19, 2006 at 09:23:20AM -0600, Shankar Anand wrote:
>>> Verified compilation when nfsv4 is configured out. And also 
>>> made changes so that the nfsv4 operation statistics are captured
>>> only when nfsv4 is configured.
>> 
>> Thanks!  Looks fine to me.
>> 
>> One last thing I wonder about--the current /proc/net/rpc/nfsd ends
with
>> lines like:
>> 
>> proc2 18 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
>> proc3 22 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
>> proc4 2 4 172
>> 
>> where the two operations counted on the last line are NULL and
COMPOUND.
>> You're appending one more line, to make:
>> 
>> proc2 18 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
>> proc3 22 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
>> proc4 2 4 172
>> proc4ops 37 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0
>> 0 0 0 0 0 0 0
>> 
>> I like the fact that that doesn't bother the preexisting proc4 line.
 On
>> the other hand, as far as we know nobody's ever used the data on
that
>> line, and it's hard to see how they would in the future (the number
of
>> NULL calls to the server isn't very important), so may it would be
>> simplest just to replace the proc4 line entirely, as was done on
the
>> client side.
>> 
>> Any strong opinions from anyone else?
> 
> There are some small issues in doing that.
> 
> The proc2, proc3 and proc4 lines get written into the /proc file by 
> rpc_proc_show() function in sunrpc library unlike the proc4ops line
that 
> I have written now, which gets written into /proc file at nfs level
in 
> nfs_proc_show().
> 
> All the procedures that are registered as rpc procedures, get their 
> statistics 
> recorded in the /proc file in the sunrpc rpc_proc_show() function. If
we 
> have to avoid the original proc4 line, we will have to introduce a
special 
> case 
> to specifically refrain from writing v4 rpc statistics into the /proc
file, 
> which may not be appropriate.
> 
> In the client, all the procedures are registered as rpc procedures in

> nfs4xdr.c.
> Hence, the proc4 line for the client contains all the v4 procedures.

Is adding the proc4ops line ok? Are these patches ok with everyone?
Please get back if you have comments.

Cheers,
Shankar
