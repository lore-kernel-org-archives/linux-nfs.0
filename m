From: Vincent ROQUETA <vincent.roqueta@ext.bull.net>
Subject: I don(t understand....
Date: Fri, 23 Jan 2004 10:51:25 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200401231051.25758.vincent.roqueta@ext.bull.net>
Reply-To: vincent.roqueta@ext.bull.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ajxxm-0003HP-Eh
	for nfs@lists.sourceforge.net; Fri, 23 Jan 2004 01:50:54 -0800
Received: from ecbull20.frec.bull.fr ([129.183.4.3])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ajxxl-0004in-G9
	for nfs@lists.sourceforge.net; Fri, 23 Jan 2004 01:50:53 -0800
Received: from roquetav.frec.bull.fr (roquetav.frec.bull.fr [129.183.101.52])
	by ecbull20.frec.bull.fr (8.9.2/8.9.1) with ESMTP id KAA13920
	for <nfs@lists.sourceforge.net>; Fri, 23 Jan 2004 10:51:34 +0100
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

in file nfs4state :



static struct nfs4_state_owner *
nfs4_alloc_state_owner(void)
{
        struct nfs4_state_owner *sp;

        sp = kmalloc(sizeof(*sp),GFP_KERNEL);
        if (!sp)
                return NULL;



        init_MUTEX(&sp->so_sema); -> Ok


        sp->so_seqid = 0;                 /* arbitrary */
        INIT_LIST_HEAD(&sp->so_states);
        atomic_set(&sp->so_count, 1);
        return sp;
}


Well... I'm looking where the mutex is destroyed, in the
nfs4_free_client ??


-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
