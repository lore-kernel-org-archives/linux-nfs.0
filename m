From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] Timeouts gone wild on ia64
Date: Thu, 15 May 2003 11:33:00 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3EC3B32C.6000900@RedHat.com>
References: <482A3FA0050D21419C269D13989C6113127DC8@lavender-fe.eng.netapp.com>	<3EC39FDF.60609@RedHat.com> <16067.42148.524146.39488@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: "Lever, Charles" <Charles.Lever@netapp.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from nat-pool-rdu.redhat.com ([66.187.233.200] helo=lacrosse.corp.redhat.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19GKjC-0004ji-00
	for <nfs@lists.sourceforge.net>; Thu, 15 May 2003 08:33:06 -0700
To: trond.myklebust@fys.uio.no
In-Reply-To: <16067.42148.524146.39488@charged.uio.no>
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Trond Myklebust wrote:

>With a properly implemented algorithm, the number of retransmits
>should be small anyway as it is supposed to take into account the
>variance on the estimated RTO. We don't want any extra artificial
>limits if we can avoid it.
>
I totally greed... But this change, IMHO, will give a better estimated RTO
since all of the constants are based on the machine's HZ... At
least that's how I saw it...

>You may well be right in asserting that we're setting the initial RTO
>estimate too low, but then the answer should be to increase the value
>of the 'timeo' mount parameter as that is what defines the initial
>estimate.
>The default value of 'retrans' should also be looked at. I'm not at
>all comfortable with a default retrans value of '3' when doing soft
>mounts.
>
This was the direction I was headed until I saw the minimal RTO was
not HZ based... When I changed that which seem to take care of the
problem... I just stopped there... :(

>At the moment I believe that the default values for these 2 parameters
>differ in the kernel from those in the 'mount' program. IMHO, the
>mount program is overriding the kernel with too low values. It would
>be better if 'mount' did not set timeo/retrans (unless the user
>overrides) and left that to the kernel.
>
This definitely seems wrong....

SteveD.




-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
