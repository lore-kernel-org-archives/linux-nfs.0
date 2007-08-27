From: Gabriel Barazer <gabriel@oxeva.fr>
Subject: Re: nfs4 filesystem mounted via the "bind" option reports
	wrong	fstype
Date: Mon, 27 Aug 2007 22:08:15 +0200
Message-ID: <46D32F2F.3050408@oxeva.fr>
References: <46D318D3.9020101@oxeva.fr> <20070827184059.GI3118@fieldses.org>
	<20070827191507.GI21089@ftp.linux.org.uk>
	<20070827193242.GJ3118@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, nfsv4@linux-nfs.org,
	linux-kernel@vger.kernel.org, jkar8572@users.sourceforge.net,
	Al Viro <viro@ftp.linux.org.uk>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IPksp-0003FP-0z
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 13:08:23 -0700
Received: from mail.reagi.com ([195.60.188.80])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IPksr-0005gZ-Rd
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 13:08:27 -0700
In-Reply-To: <20070827193242.GJ3118@fieldses.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On 08/27/2007 9:32:42 PM +0200, "J. Bruce Fields" <bfields@fieldses.org> 
wrote:
> On Mon, Aug 27, 2007 at 08:15:07PM +0100, Al Viro wrote:
>> On Mon, Aug 27, 2007 at 02:40:59PM -0400, J. Bruce Fields wrote:
>>  
>>> There's no reason not to just mount server:/exports/data directly at
>>> /home/data; the bind mounts are just a workaround for the somewhat
>>> primitive exports facility on the server side.
>> Bullshit.  Bindings are first-class operations on _client_, regardless
>> of fs types involved.
> 
> I know.  Did I say something to the contrary?
> 
> Maybe I was too terse; in more detail: the original poster appears to be
> mounting server:/exports/data by first mounting server:/ somewhere and
> then bind-mounting the exports/data someplace else.  I couldn't see an
> obvious reason they'd be using two steps instead of just performing a
> single mount of server:/exports/data.
> 
> So my assumption was that this was due to a confused memory of some
> server-side setup instructions. (On the server side, nfs4 export setup
> often requires the administrator to do some extra bind mounts which
> shouldn't really be necessary.)

Right. When setting up the clients, I remembered these "bind" mount 
things, and applied the same client-side because at this time I had 
other bugs for which I thought "bind" mount was the solution. In fact 
it's not, but as nfs4 is seen as a unique filesystem and I had several 
exported volumes, It was easier to mount the nfsv4 pseudoroot, then 
"bind" mount all the volumes from it.

But the bug's still here, and since these additional mounts appear 
"magically" in /proc/mounts, I don't know where to look at in the kernel 
source. The nfsv4 client code must have somewhere a kind of nfs4 
automounter for "nohide" volumes. A bit ugly IMHO, but the only way to 
show quotas for separates nfsv4 exported volumes too.

Gabriel

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
