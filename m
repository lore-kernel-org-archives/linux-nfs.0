From: Denis Vlasenko <vda@ilport.com.ua>
Subject: BUG(?): resolved hostnames in etab instead of IPs
Date: Fri, 4 Mar 2005 13:49:06 +0200
Message-ID: <200503041349.06923.vda@ilport.com.ua>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D7BJp-0008JL-Ie
	for nfs@lists.sourceforge.net; Fri, 04 Mar 2005 03:50:09 -0800
Received: from [195.66.192.168] (helo=port.imtp.ilyichevsk.odessa.ua)
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.41)
	id 1D7BJU-0000Sk-Ju
	for nfs@lists.sourceforge.net; Fri, 04 Mar 2005 03:50:09 -0800
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
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

I'm doing my testing locally, therefore I use 127.0.0.1,
but I believe this will happen with any numeric IP:

# cat /etc/exports
/       127.0.0.1(rw,no_root_squash,async)
# rm /var/lib/nfs/etab
# exportfs -r
# cat /var/lib/nfs/etab
/       localhost(rw,async,wdelay,hide,nocrossmnt,secure,no_root_squash,no_all_squash,subtree_check,secure_locks,mapping=identity,anonuid=-2,anongid=-2)

Looks like bug to me, because I said explicitly that I allow 127.0.0.1 to mount /,
not it's hostname.

One of consequences of this bug is mount failures if mountd gets restarted while
name resolution isn't working (DNS server down etc).

In case this is indeed a bug, here is where it happens.
(I'm not sure I will be able to cook up a sane patch
so at least I'll try to explain how 'exportfs -r' did it):

int main(...)
-> int export_read(char *fname)
-> nfs_export* export_lookup(char *hname, char *path, int canonical)
-> nfs_client* client_lookup(char *hname, int canonical)

nfs-utils-1.0.7/support/export/client.c:
nfs_client *
client_lookup(char *hname, int canonical)
{
        nfs_client      *clp = NULL;
        int             htype;
        struct hostent  *hp = NULL;

        htype = client_gettype(hname);

        if (htype == MCL_FQDN && !canonical) {
                struct hostent *hp2;
                hp = gethostbyname(hname);
                if (hp == NULL || hp->h_addrtype != AF_INET) {
                        xlog(L_ERROR, "%s has non-inet addr", hname);
                        return NULL;
                }
                /* make sure we have canonical name */
                hp2 = hostent_dup(hp);
HERE ====>      hp = gethostbyaddr(hp2->h_addr, hp2->h_length,
                                   hp2->h_addrtype);
                if (hp) {

Hmm... maybe we need to introduce MCL_NUMERIC_IP or something like that?
--
vda



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
