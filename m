From: "William Knop" <w_knop@hotmail.com>
Subject: Re: status
Date: Mon, 18 Nov 2002 12:34:00 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <F170m8eyLahVRaWhrkZ0001357e@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
To: NFS@lists.sourceforge.net
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

Ah, doesn't NFSv3 not support concurrent reads? Or concurrent reads while a 
file is open for writing or something like that? Concurrent writes would be 
useful, but is not necessarily required (we could hack around it). Idealy, 
we'd like to have a job continue to read off the version of a file it 
started reading on, such that when the file already opened for reading is 
opened for writing, the file is duplicated, the duplicate writen to (now the 
new version), then deleted once the initial job closes the file for reading. 
This could result in many versions of the same file, but only as long as 
they are open for reading. It would be nice if I could open a file for a 
"sustained read" or some such, so only big jobs would receive the special 
treatment of getting their own temporary version of a file.


>NFSv4 for Linux is about three months out.  a beta quality                  
>                                                                            
>                 > client will be available soon, but the server is farther 
>                                                                            
>                                    > out.                                  
>                                                                            
>                                                                            
>                                                                            
>                                                                        > 
>what are your performance requirements, and why do you                      
>                                                                            
>                 > think NFSv3 won't meet them?
>
>
> > I'm setting up a distributed/clustering filesystem for a                 
>                                                                            
>                  > > research group and                                    
>                                                                            
>                                     > > would like some info/advise.       
>                                                                            
>                                                        > >                 
>                                                                            
>                                                                           
> > > NFSv4 looks pretty sweet, but is it ready for beta                     
>                                                                            
>                    > > deployment? We'll need to                           
>                                                                            
>                                       > > have everything up and stable 
>fairly soon, but so far it                                                  
>                                                            > > seems like 
>NFSv4 is                                                                    
>                                                                            
>    > > the only open source FS out there that will satisfy our             
>                                                                            
>                       > > requirements, of                                 
>                                                                            
>                                          > > which the main ones are 
>partial-file caching and support for                                        
>                                                                  > > large 
>(100GB+)                                                                    
>                                                                            
>         > > filesystems.                                                   
>                                                                            
>                            > >                                             
>                                                                            
>                                               > > Intermezzo forces whole 
>file caching, which will not do.                                            
>                                                                  > > 
>OpenGFS I believe                                                           
>                                                                            
>               > > is still in alpha stage. OpenAFS only allows for very 
>small                                                                       
>                                    > > filesystems.                        
>                                                                            
>                                                       > > EVMS looks 
>promising, but the clustering FS part is still                              
>                                                                            
>    > > alpha. I think                                                      
>                                                                            
>                       > > NFSv3 has poor performance, although it would be 
>excellent if                                                                
>                                         > > it would work.                 
>                                                                            
>                                                            > >             
>                                                                            
>                                                                            
>    > > I'd greatly appreciate any info on distributed/clustering           
>                                                                            
>                       > > filesystems,                                     
>                                                                            
>                                          > > especially NFSv4 or stable 
>alternatives.
> > > Thanks much,
> > William Knop

_________________________________________________________________
Add photos to your messages with MSN 8. Get 2 months FREE*. 
http://join.msn.com/?page=features/featuredemail



-------------------------------------------------------
This sf.net email is sponsored by: To learn the basics of securing 
your web site with SSL, click here to get a FREE TRIAL of a Thawte 
Server Certificate: http://www.gothawte.com/rd524.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
