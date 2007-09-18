From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] export man page updated.
Date: Tue, 18 Sep 2007 07:07:03 -0400
Message-ID: <46EFB157.4010508@RedHat.com>
References: <46EE9E73.1070002@RedHat.com> <46EEAF51.5010400@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IXayf-0000Cg-GS
	for nfs@lists.sourceforge.net; Tue, 18 Sep 2007 04:10:49 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IXayk-0000Xp-1w
	for nfs@lists.sourceforge.net; Tue, 18 Sep 2007 04:10:54 -0700
In-Reply-To: <46EEAF51.5010400@oracle.com>
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



Chuck Lever wrote:
> Steve Dickson wrote:
>> It was pointed that the exportfs man page talks about
>> the wrong file. In 2.6 kernels the export information
>> is now kept in /var/lib/nfs/etab not /var/lib/nfs/xtab.
>>
>> This patch basically does a 's/xtab/etab' and is relative
>> to the to the Fedora git tree
>>
>> git://git.infradead.org/~steved/nfs-utils.fedora
> 
> Hrm, an attachment.
hmm... are you not seeing the attachments inlined?

> 
> @@ -93,8 +93,8 @@ file, so that only default options and options given 
> on the command
>  line are used.
>  .TP
>  .B -r
> -Reexport all directories. It synchronizes /var/lib/nfs/xtab
> -with /etc/exports. It removes entries in /var/lib/nfs/xtab
> +Reexport all directories. It synchronizes /var/lib/nfs/etab
> +with /etc/exports. It removes entries in /var/lib/nfs/etab
>  which are deleted from /etc/exports, and remove any entries from the
>  kernel export table which are no longer valid.
>  .TP
> 
> In this hunk, why isn't the file name bold, like the others?
Thats the way it was. If its a problem, I'll respin the patch...

steved.


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
