From: Jean-Eric Cuendet <jean-eric.cuendet@linkvest.com>
Subject: Re: rpc.mountd + rpc.nfsd
Date: Tue, 03 Sep 2002 12:37:08 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3D7490D4.7050307@linkvest.com>
References: <3D7363A7.8090906@linkvest.com>	<15732.7907.19389.156631@notabene.cse.unsw.edu.au>	<3D745D10.4040409@linkvest.com> <15732.35929.482032.954554@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
To: nfs@sourceforge.net
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

I'm developing (beginning...) an SMB to NFS bridge.
That means an NFS server that gets its data, files, ACLs, etc... to SMB 
servers (Samba or Windows).
To begin, I'll take the sources of nfs-server userspace. But there is 2 
daemons while (I think) only one is necessary.
Would it be OK (In terms of kernel and RPC interactivity) to have only 
one daemon that do mountd+nfsd?

The goal of this project is to have a fully browseable /smb directory.
That will be:
/smb --|-- DOMAIN --|-- SERVER --|-- Share --|-- file
And all that authenticate in a per user way. That means that all 
connected users would be able to access /smb while seeing only what 
their credentials allow them. Even root in the machine won't be able to 
see every connected user data (root could always dump memory and find 
credentials..., but it's a lot harder to do than just su - user and go 
to the NFS mounted dir...)

What do you think of that?

-jec

PS: There is a similar commercial product called sharity 
(http://www.obdev.at/products/sharity/)

Neil Brown wrote:

>On Tuesday September 3, Jean-Eric.Cuendet@linkvest.com wrote:
>  
>
>>In fact, I thought of a completely userspace daemon. I took 
>>nfs-server-userspace-2.2b47 from the net and wondered why there was 2 
>>daemons while one is IMHO enough.
>>So, separating things between things that relates is sometimes good, but 
>>sometimes, it add complexity.
>>Any comment? Why 2 daemons in userspace. And the 2 run as root (I think...)
>>    
>>
>
>Probably conceptually simpler.... but you are getting into ancient
>history here.  The user-space NFS server has it's origins well over a
>decade ago (about 15 years I think) and has passed through many hands
>on the way.  Finding a definitive answer would be hard.
>
>NeilBrown
>  
>

-- 
Jean-Eric Cuendet
Linkvest SA
Av des Baumettes 19, 1020 Renens Switzerland
Tel +41 21 632 9043  Fax +41 21 632 9090
E-mail: jean-eric.cuendet@linkvest.com
http://www.linkvest.com
--------------------------------------------------------






-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
