From: Benjamin LaHaise <bcrl@redhat.com>
Subject: Re: Tracking rpc errors 'svc: unknown version (0)'
Date: Wed, 17 Jul 2002 11:27:32 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020717112732.A2361@redhat.com>
References: <78B78720E680564CB7302950FA6CCF17D302EB@james.fs.apu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from to-velocet.redhat.com ([216.138.202.10] helo=touchme.toronto.redhat.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17UqiE-0001DY-00
	for <nfs@lists.sourceforge.net>; Wed, 17 Jul 2002 08:27:34 -0700
To: Jarod Beekman <JBeekman@apu.edu>
In-Reply-To: <78B78720E680564CB7302950FA6CCF17D302EB@james.fs.apu.edu>; from JBeekman@apu.edu on Wed, Jul 17, 2002 at 07:41:02AM -0700
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

On Wed, Jul 17, 2002 at 07:41:02AM -0700, Jarod Beekman wrote:
> I upgraded our nfs server from 2.4.9-34 Redhat 7.2 to 2.4.18-5 Redhat
> 7.3 and I am now seeing 'svc: unknown version (0)' errors.  Poking
> around on the list and the net tells me that this is a reflection of an
> unrecognized rpc request.  Is this correct, and if so is there a way to
> track down the source and nature of the request?  Thanks for your help.

Whoops, that's a patch that got lost between 2.4.9-34 and 2.4.18-5.  The 
message is a null rpc request, and can be safely ignored.

		-ben
-- 
"You will be reincarnated as a toad; and you will be much happier."


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
