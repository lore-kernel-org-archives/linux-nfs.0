From: Bruce Allan <bruce.allan@us.ibm.com>
Subject: Re: slow NFS performance extracting bits from large files
Date: Mon, 16 Dec 2002 09:27:49 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <OF5780D600.FCFDD312-ON88256C91.005F9A85@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: nfs@lists.sourceforge.net, nfs-admin@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: Bruce Allen <ballen@gravity.phys.uwm.edu>
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





Hi Bruce (good name, btw),

It would help if you posted information about your network.  Alternately,
you could read the "Optimizing NFS Performance" section of the Linux
NFS-HOWTO located at http://nfs.sourceforge.net/nfs-howto/

Regards,
---
Bruce Allan  <bruce.allan@us.ibm.com>
Software Engineer, Linux Technology Center
IBM Corporation, Beaverton OR
503-578-4187   IBM Tie-line 775-4187



                                                                                                                                    
                      Bruce Allen                                                                                                   
                      <ballen@gravity.phys        To:       nfs@lists.sourceforge.net                                               
                      .uwm.edu>                   cc:       Bruce Allen <ballen@gravity.phys.uwm.edu>                               
                      Sent by:                    Subject:  [NFS] slow NFS performance extracting bits from large files             
                      nfs-admin@lists.sour                                                                                          
                      ceforge.net                                                                                                   
                                                                                                                                    
                                                                                                                                    
                      12/15/2002 11:02 PM                                                                                           
                                                                                                                                    
                                                                                                                                    



I've searched/browsed the mail archive and the online documentation but am
still a bit clueless about where to start.

I am working on a scientific data analysis application which needs to
extract a little bit of data from around 10,000 files.  The files
themselves are each around 1 MB in size. The application does:

for (i=0; i<10000; i++){
  open() ith file
  read() 32 bytes from beginning
  lseek() to somewhere in the middle of the file
  read() 620 bytes from the middle of the file
  close() ith file
}

If I run this with the data set on a local disk, the total run time is
around 1 sec -- very reasonable since I am transferring around 6 MB of
data.

If I run this on an NFS-mounted disk the performance is 100 times worse.
Both client and server are stock RH 7.3.  Note that if I run it a second
time, when the data is presumably cached, it takes just a few seconds to
run.

Is it obvious what needs to be changed/tuned to improve this performance?
Or if not, could someone suggest a tool and a strategy for tracing down
the cause of the poor performance?

Sincerely,
             Bruce Allen




-------------------------------------------------------
This sf.net email is sponsored by:
With Great Power, Comes Great Responsibility
Learn to use your power at OSDN's High Performance Computing Channel
http://hpc.devchannel.org/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs





-------------------------------------------------------
This sf.net email is sponsored by:
With Great Power, Comes Great Responsibility 
Learn to use your power at OSDN's High Performance Computing Channel
http://hpc.devchannel.org/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
