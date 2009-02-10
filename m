From: "Gary L. Grobe" <gary@grobe.net>
Subject: Re:  processes in D state too long too often
Date: Tue, 10 Feb 2009 01:04:10 +0000
Message-ID: <W27744109726791234227850@webmail24>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	"Andrew Morton" <akpm@linux-foundation.org>
To: "J. Bruce Fields" <bfields@fieldses.org>,
	"Gary L. Grobe" <gary@grobe.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754268AbZBJBEY@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>Presumably that's the msleep(10) in nfsd_vfs_write().
>
>That wouldn't explain the same nfsd thread waiting for several seconds,
>though.  Or was it just that that several seconds during which different
>nfsd threads were stuck in D, not necessarily the same ones?
>
>What does your /etc/exports file look like on the server, and what are
>the mount options on the client?
>
>You could try turning off that msleep() with no_wdelay, but it may not
>help.
>
>The more likely explanation is that you just switched to a more recent
>distro where "sync" (as opposed to "async") is the option.  Depending on
>workload, "async" may improve performance a great deal, at the expense
>of possible data corruption on server reboot!
>
>If you're doing a lot of writing and using NFSv2, then switching to
>NFSv3 may give you performance close to the "async" performance without
>the corruption worries.

Apologies for the unintentional separate thread.

I really think I'm seeing the same nfsd threads going into D for a very short time. Here's what's in /etc/exports ...

/diskless/10.0.1.1 10.0.1.1(sync,rw,no_root_squash,no_all_squash,no_subtree_check)
/diskless/10.0.1.2 10.0.1.2(sync,rw,no_root_squash,no_all_squash,no_subtree_check)
/diskless/10.0.1.3 10.0.1.3(sync,rw,no_root_squash,no_all_squash,no_subtree_check)
# ... same lines above for another 80+ nodes

# Common to all slave nodes.
/usr    10.0.0.0/16(sync,ro,subtree_check,no_root_squash,no_all_squash)
/opt    10.0.0.0/16(sync,rw,no_subtree_check,no_root_squash,no_all_squash)
/home   10.0.0.0/16(sync,rw,no_subtree_check,no_root_squash,no_all_squash)
#/var/log 10.0.0.0/16(sync,rw,subtree_check,no_root_squash,no_all_squash)

Mount options on each client are as follows ...

10.0.0.10:/diskless/10.0.1.1    /   nfs     sync,hard,intr,rw,rsize=8192,wsize=8192 0   0
10.0.0.10:/opt          /opt    nfs sync,hard,intr,rw,rsize=8192,wsize=8192 0   0
10.0.0.10:/usr          /usr    nfs sync,hard,intr,ro,rsize=8192,wsize=8192 0   0
10.0.0.10:/home         /home   nfs sync,hard,intr,rw,rsize=8192,wsize=8192 0   0
none                    /proc   proc    defaults    0 0
#10.0.0.10:/var/log     /var/log nfs    sync,hard,intr,rw   0 0

I'm not following turning off the msleep() option. Where are you referring to this from?

I've got NFSv3 enabled and have used this in a previous installation (using the same distro, gentoo) on this same hardware with no issues, and 'sync', and the performance was much better. Something worth noting, I've rolled back my kernel several times now and each time I go back (w/ same vers on master and slave node), the D state time in simulation processes keeps getting better (cut down). I went from 2.6.27-r7 to 2.6.24-r8 and now I'm running 2.6.20-r10, and each one better than the previous (and later) kernel. I was running 2.6.18-r2 in the past, which I'm having difficulties getting at the moment.
