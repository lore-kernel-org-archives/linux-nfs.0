From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: Server not working since 2.6.20-rc
Date: Tue, 20 Feb 2007 18:40:44 -0500
Message-ID: <4d569c330702201540k641f6a32i204006f7e22a2ebc@mail.gmail.com>
References: <45DB8447.1060903@sysnux.pf>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Jean-Denis Girard" <jd.girard@sysnux.pf>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HJebD-0005ei-NO
	for nfs@lists.sourceforge.net; Tue, 20 Feb 2007 15:40:43 -0800
Received: from an-out-0708.google.com ([209.85.132.250])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HJebF-0002C7-Jt
	for nfs@lists.sourceforge.net; Tue, 20 Feb 2007 15:40:45 -0800
Received: by an-out-0708.google.com with SMTP id d40so812573and
	for <nfs@lists.sourceforge.net>; Tue, 20 Feb 2007 15:40:45 -0800 (PST)
In-Reply-To: <45DB8447.1060903@sysnux.pf>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On 2/20/07, Jean-Denis Girard <jd.girard@sysnux.pf> wrote:
> Hi list,
>
> I have an LTSP environment, which is working fine with kernels before
> 2.6.20 series. I think I started to test with 2.6.20-rc3, up to latest
> 2.6.20.1, but mounting nfs shares from the clients fails with
> "permission denied". If I reboot server to 2.6.19.x without changing
> configuration, it works again.
>
> When I try to mount /home from my laptop (with kernel 2.6.20), I get the
> well known message:
>         mount: tiare.sysnux.pf:/home failed, reason given by server: Permission
> denied
>
> But, on the server I have:
> [jdg@tiare ~]$ cat /proc/fs/nfs/exports
> # Version 1.1
> # Path Client(Flags) # IPs
> /home
> 192.168.10.0/255.255.255.0(rw,insecure,root_squash,sync,wdelay,no_subtree_check,insecure_locks)
>
> Client and server are based on Mandriva 2007. Server is 64 bits SMP.
> nfs-utils has been updated to 1.0.10. I can provide more details if needed.
>
> I think I have done all checks recommended in the troubleshooting
> section of the nfs-howto. Any help would be greatly appreciated.
>

This patch from Bruce worked for me:

--- a/net/sunrpc/svcsock.c~copy_address_correctly       2007-02-06
16:55:30.000000000 -0500
+++ b/net/sunrpc/svcsock.c      2007-02-12 14:27:59.000000000 -0500
@@ -1038,7 +1038,7 @@
        if (!(newsvsk = svc_setup_socket(serv, newsock, &err,
                                 (SVC_SOCK_ANONYMOUS | SVC_SOCK_TEMPORARY))))
                goto failed;
-       memcpy(&newsvsk->sk_remote, &sin, slen);
+       memcpy(&newsvsk->sk_remote, sin, slen);
        newsvsk->sk_remotelen = slen;

        /* make sure that we don't have too many active connections.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
